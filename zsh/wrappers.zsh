# Decrypt a gpg-encrypted file into a private tmp file; print its path on
# success, or return 1 (printing nothing) on failure. Caller removes the
# tmp file when done.
_gpg_decrypt_to_tmp() {
    local gpg_source="$1"
    local prefix="$2"
    local tmpfile
    tmpfile=$(mktemp "${TMPDIR:-/tmp}/${prefix}.XXXXXX") || return 1
    chmod 0600 "$tmpfile"

    if ! gpg -q -d "$gpg_source" > "$tmpfile" 2>/dev/null || [[ ! -s "$tmpfile" ]]; then
        rm -f "$tmpfile"
        return 1
    fi

    print -r -- "$tmpfile"
}

# Decrypt ~/.pgpass.gpg into a tmp file.
pg_dump_safe() {
    setopt localoptions localtraps
    local tmpfile
    tmpfile=$(_gpg_decrypt_to_tmp ~/.pgpass.gpg .pgpass) || { echo "pg_dump: failed to decrypt credentials" >&2; return 1; }
    trap 'rm -f "$tmpfile"' EXIT INT TERM

    PGPASSFILE="$tmpfile" command pg_dump "$@"
    local exit_status=$?
    rm -f "$tmpfile"
    return $exit_status
}
alias pg_dump=pg_dump_safe

# If a `service=<name>` arg names a tunneled service (see zsh/pg_tunnels.zsh),
# make sure its SSH tunnel is up (reusing one already running) before psql
# needs it. Returns 1 (with a message) if the tunnel can't be established.
_pg_tunnel_ensure() {
    setopt localoptions localtraps
    local service="$1"
    local mapping="${PG_TUNNEL_SERVICES[$service]}"
    [[ -z "$mapping" ]] && return 0

    mkdir -p -m 700 "$PG_TUNNEL_STATE_DIR" 2>/dev/null
    local lockdir="$PG_TUNNEL_STATE_DIR/$service.lock"

    local waited=0
    while ! mkdir "$lockdir" 2>/dev/null; do
        sleep 0.2
        (( waited++ ))
        if (( waited > 50 )); then
            echo "psql: timed out waiting for tunnel lock ($service)" >&2
            return 1
        fi
    done
    # Fallback for an interrupt mid-function; the lockdir path is baked into
    # the trap string now since a local var wouldn't survive the EXIT trap
    # firing after a normal `return` unwinds this scope. Real cleanup for the
    # normal path happens explicitly below.
    eval "trap 'rmdir \"$lockdir\" 2>/dev/null' INT TERM"

    _pg_tunnel_ensure_locked "$service" "$mapping"
    local ensure_status=$?
    rmdir "$lockdir" 2>/dev/null
    return $ensure_status
}

_pg_tunnel_ensure_locked() {
    local service="$1"
    local mapping="$2"
    local local_port="${mapping%%:*}"
    local remote_host="${mapping#*:}"

    local pidfile="$PG_TUNNEL_STATE_DIR/$service.pid"
    local lastactive_file="$PG_TUNNEL_STATE_DIR/$service.lastactive"

    local existing_pid=""
    [[ -f "$pidfile" ]] && existing_pid=$(<"$pidfile")

    if [[ -n "$existing_pid" ]] \
        && kill -0 "$existing_pid" 2>/dev/null \
        && ps -p "$existing_pid" -o comm= 2>/dev/null | grep -q ssh \
        && lsof -nP -iTCP:"$local_port" -sTCP:LISTEN -t 2>/dev/null | grep -qx "$existing_pid"; then
        date +%s > "$lastactive_file"
        return 0
    fi

    rm -f "$pidfile" "$lastactive_file"

    if ! ssh_safe -f -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=30 \
        -L "${local_port}:localhost:5432" "postgres@${remote_host}"; then
        echo "psql: failed to open tunnel to $remote_host for service $service" >&2
        return 1
    fi

    # ssh -f daemonizes: the process we just ran exits once auth completes,
    # and a new backgrounded process continues, so $! isn't useful here.
    local new_pid="" attempt=0
    while (( attempt < 25 )); do
        new_pid=$(pgrep -f "ssh .*-L ${local_port}:localhost:5432.*${remote_host}" | head -n1)
        [[ -n "$new_pid" ]] && break
        sleep 0.2
        (( attempt++ ))
    done

    if [[ -z "$new_pid" ]]; then
        echo "psql: could not locate backgrounded ssh tunnel process for $service" >&2
        return 1
    fi

    attempt=0
    until nc -z localhost "$local_port" 2>/dev/null; do
        (( attempt++ ))
        if (( attempt > 25 )); then
            echo "psql: tunnel for $service did not become ready in time" >&2
            kill "$new_pid" 2>/dev/null
            return 1
        fi
        sleep 0.2
    done

    echo "$new_pid" > "$pidfile"
    date +%s > "$lastactive_file"
    return 0
}

# Decrypt ~/.pgpass.gpg into a tmp file. If a `service=<name>` arg names a
# tunneled service, ensure its SSH tunnel is up first (see _pg_tunnel_ensure).
psql_safe() {
    setopt localoptions localtraps
    local arg service_name
    for arg in "$@"; do
        if [[ "$arg" == service=* ]]; then
            service_name="${arg#service=}"
            break
        fi
    done
    if [[ -n "$service_name" ]] && (( ${+PG_TUNNEL_SERVICES[$service_name]} )); then
        _pg_tunnel_ensure "$service_name" || return 1
    fi

    local tmpfile
    tmpfile=$(_gpg_decrypt_to_tmp ~/.pgpass.gpg .pgpass) || { echo "psql: failed to decrypt credentials" >&2; return 1; }
    trap 'rm -f "$tmpfile"' EXIT INT TERM

    PGPASSFILE="$tmpfile" command psql "$@"
    local exit_status=$?
    rm -f "$tmpfile"
    return $exit_status
}
alias psql=psql_safe

# Decrypt ~/.aws/credentials.gpg into a tmp file.
aws_safe() {
    setopt localoptions localtraps
    local tmpfile
    tmpfile=$(_gpg_decrypt_to_tmp ~/.aws/credentials.gpg .aws_credentials) || { echo "aws: failed to decrypt credentials" >&2; return 1; }
    trap 'rm -f "$tmpfile"' EXIT INT TERM

    AWS_SHARED_CREDENTIALS_FILE="$tmpfile" command aws "$@"
    local exit_status=$?
    rm -f "$tmpfile"
    return $exit_status
}
alias aws=aws_safe

# Decrypt ~/.ssh/id_rsa.gpg into a tmp file.
# Note: for backgrounded/detached sessions (e.g. `ssh -f`), this function
# returns (and its cleanup trap fires) as soon as ssh forks, before the
# detached process is necessarily done with the key. Fine for normal auth
# (key is only needed pre-fork), but avoid relying on `-f` with this wrapper.
ssh_safe() {
    setopt localoptions localtraps
    local tmpfile
    tmpfile=$(_gpg_decrypt_to_tmp ~/.ssh/id_rsa.gpg .ssh_id_rsa) || { echo "ssh: failed to decrypt credentials" >&2; return 1; }
    trap 'rm -f "$tmpfile"' EXIT INT TERM

    command ssh -i "$tmpfile" "$@"
    local exit_status=$?
    rm -f "$tmpfile"
    return $exit_status
}
alias ssh=ssh_safe
