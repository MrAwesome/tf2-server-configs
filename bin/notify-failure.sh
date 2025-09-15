#!/bin/bash

set -euxo pipefail

unit="${1:-unknown}"
to="root@localhost"
if [[ -d "$HOME" ]]; then
    homedir="$HOME"
else
    homedir="/root"
fi
if [[ -f "$homedir"/.tf2_admin_email ]]; then
    to="$(cat "$homedir"/.tf2_admin_email)"
fi
subj="ALERT: $unit exceeded failure threshold"
body=$(printf "Unit: %s\n\nStatus:\n%s\n\nRecent journal:\n%s\n" \
  "$unit" \
  "$(systemctl status --no-pager "$unit")" \
  "$(journalctl -u "$unit" -n 200 --no-pager)")

echo "Sent email to $to with subject: '$subj'"

printf '%s\n' "$body" | /usr/bin/mail -s "$subj" "$to"
