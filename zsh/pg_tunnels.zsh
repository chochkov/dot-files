# Shared config for the psql SSH-tunnel wrappers (zsh/wrappers.zsh) and the
# idle reaper (scripts/pg-tunnel-reaper.sh). Sourced by both, so the
# service -> port/host table only lives in one place.

typeset -gA PG_TUNNEL_SERVICES=(
    dwh5 "5435:dwh5.flowkey.com"
    dwh6 "5436:dwh6.flowkey.com"
)

PG_TUNNEL_STATE_DIR="$HOME/.cache/pg-tunnels"
PG_TUNNEL_IDLE_TIMEOUT=1800
