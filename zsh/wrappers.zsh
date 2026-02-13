# Decrypt ~/.pgpass.gpg into a tmp file.
pg_dump_safe() {
    local TMP_PGPASS=$(mktemp /tmp/.pgpass.XXXXXX)
    gpg -q -d ~/.pgpass.gpg > "$TMP_PGPASS"
    chmod 0600 "$TMP_PGPASS"
    ((sleep 2; rm -f "$TMP_PGPASS") & disown) > /dev/null 2>&1

    PGPASSFILE="$TMP_PGPASS" command pg_dump "$@"
}
alias pg_dump=pg_dump_safe

# Decrypt ~/.pgpass.gpg into a tmp file.
psql_safe() {
    local TMP_PGPASS=$(mktemp /tmp/.pgpass.XXXXXX)
    gpg -q -d ~/.pgpass.gpg > "$TMP_PGPASS"
    chmod 0600 "$TMP_PGPASS"
    ((sleep 2; rm -f "$TMP_PGPASS") & disown) > /dev/null 2>&1

    PGPASSFILE="$TMP_PGPASS" command psql "$@"
}
alias psql=psql_safe

# Decrypt ~/.aws/credentials.gpg into a tmp file.
aws_safe() {
    local TMP_CREDS=$(mktemp /tmp/.aws_credentials.XXXXXX)
    gpg -q -d ~/.aws/credentials.gpg > "$TMP_CREDS"
    chmod 0600 "$TMP_CREDS"
    ((sleep 2; rm -f "$TMP_CREDS") & disown) > /dev/null 2>&1

    AWS_SHARED_CREDENTIALS_FILE="$TMP_CREDS" command aws "$@"
}
alias aws=aws_safe

# Decrypt ~/.ssh/id_rsa.gpg into a tmp file.
ssh_safe() {
    local TMP_CREDS=$(mktemp /tmp/.ssh_id_rsa.XXXXXX)
    gpg -q -d ~/.ssh/id_rsa.gpg > "$TMP_CREDS"
    chmod 0600 "$TMP_CREDS"
    ((sleep 2; rm -f "$TMP_CREDS") & disown) > /dev/null 2>&1

    command ssh -i "$TMP_CREDS" "$@"
}
alias ssh=ssh_safe
