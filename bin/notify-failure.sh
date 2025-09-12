#!/bin/bash
UNIT="$1"
TO="root@localhost"
if [[ -d "$HOME" ]]; then
    homedir="$HOME"
else
    homedir="/root"
fi
if [[ -f "$homedir"/.tf2_admin_email ]]; then
    TO="$(cat "$homedir"/.tf2_admin_email)"
fi
SUBJ="ALERT: $UNIT exceeded failure threshold"
BODY=$(printf "Unit: %s\n\nStatus:\n%s\n\nRecent journal:\n%s\n" \
  "$UNIT" \
  "$(systemctl status --no-pager "$UNIT")" \
  "$(journalctl -u "$UNIT" -n 200 --no-pager)")

echo "Sent email to $TO with subject: '$SUBJ'"

printf '%s\n' "$BODY" | /usr/bin/mail -s "$SUBJ" "$TO"
