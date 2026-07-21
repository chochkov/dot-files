#!/bin/zsh
# Kills SSH tunnels opened by zsh/wrappers.zsh's psql wrapper once they've
# had no active connections for PG_TUNNEL_IDLE_TIMEOUT seconds. Meant to be
# run periodically by launchagents/local.pg-tunnel-reaper.plist, not sourced
# interactively.

source "${0:A:h}/../zsh/pg_tunnels.zsh"

log() {
    print -r -- "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$PG_TUNNEL_STATE_DIR/reaper.log"
}

mkdir -p -m 700 "$PG_TUNNEL_STATE_DIR"

for pidfile in "$PG_TUNNEL_STATE_DIR"/*.pid(N); do
    service="${pidfile:t:r}"
    mapping="${PG_TUNNEL_SERVICES[$service]}"
    [[ -z "$mapping" ]] && continue
    local_port="${mapping%%:*}"

    lastactive_file="$PG_TUNNEL_STATE_DIR/$service.lastactive"
    pid=$(<"$pidfile")

    if ! kill -0 "$pid" 2>/dev/null || ! ps -p "$pid" -o comm= 2>/dev/null | grep -q ssh; then
        rm -f "$pidfile" "$lastactive_file"
        log "$service: pid $pid no longer a live ssh process, cleared stale state"
        continue
    fi

    active=$(lsof -nP -iTCP:"$local_port" -sTCP:ESTABLISHED -t 2>/dev/null | wc -l)
    now=$(date +%s)

    if (( active > 0 )); then
        print -r -- "$now" > "$lastactive_file"
        continue
    fi

    lastactive=0
    [[ -f "$lastactive_file" ]] && lastactive=$(<"$lastactive_file")
    idle_for=$(( now - lastactive ))

    if (( idle_for > PG_TUNNEL_IDLE_TIMEOUT )); then
        kill "$pid" 2>/dev/null
        rm -f "$pidfile" "$lastactive_file"
        log "$service: killed idle tunnel (pid $pid, idle ${idle_for}s)"
    fi
done
