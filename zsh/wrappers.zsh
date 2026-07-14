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

# Decrypt ~/.pgpass.gpg into a tmp file.
psql_safe() {
    setopt localoptions localtraps
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
