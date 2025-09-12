#!/bin/bash
UNIT="$1"
TO="root@localhost"
if [[ -f "$HOME"/.tf2_admin_email ]]; then
    TO="$(cat "$HOME"/.tf2_admin_email)"
fi
SUBJ="ALERT: $UNIT exceeded failure threshold"
BODY=$(printf "Unit: %s\n\nStatus:\n%s\n\nRecent journal:\n%s\n" \
  "$UNIT" \
  "$(systemctl status --no-pager "$UNIT")" \
  "$(journalctl -u "$UNIT" -n 200 --no-pager)")

printf '%s\n' "$BODY" | /usr/bin/mail -s "$SUBJ" "$TO"
