#!/bin/zsh
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <handle1> <handle2> <body>" >&2
  exit 2
fi

handle1="$1"
handle2="$2"
body="$3"

body_enc="$(
  python3 - "$body" <<'PY'
import sys
import urllib.parse

print(urllib.parse.quote(sys.argv[1], safe=""))
PY
)"

open -g "sms://open?addresses=${handle1},${handle2}&body=${body_enc}"
sleep 2

verify_draft='
tell application "System Events"
  tell process "Messages"
    if (count of windows) = 0 then error "Messages has no open window"
    tell window 1
      set toField to missing value
      set composeField to missing value
      set elems to entire contents
      repeat with e in elems
        try
          if class of e is text field and description of e is "To:" then set toField to value of e
          if class of e is text field and description of e is "Message" then set composeField to value of e
        end try
      end repeat
      return {toField, composeField}
    end tell
  end tell
end tell
'

draft_state="$(osascript -e "$verify_draft")"
case "$draft_state" in
  *"$handle1"*"$handle2"*"$body"*|*"$handle2"*"$handle1"*"$body"*) ;;
  *)
    echo "draft verification failed: $draft_state" >&2
    exit 1
    ;;
esac

pid="$(osascript -e 'tell application "System Events" to tell process "Messages" to get unix id')"

osascript -l JavaScript <<JXA
ObjC.import('ApplicationServices');
const pid = Number("${pid}");
const keycode = 36;
const down = $.CGEventCreateKeyboardEvent(null, keycode, true);
const up = $.CGEventCreateKeyboardEvent(null, keycode, false);
$.CGEventPostToPid(pid, down);
$.CGEventPostToPid(pid, up);
JXA

sleep 2

verify_sent='
tell application "System Events"
  tell process "Messages"
    if (count of windows) = 0 then error "Messages closed before verification"
    tell window 1
      set composeField to missing value
      set elems to entire contents
      repeat with e in elems
        try
          if class of e is text field and description of e is "Message" then
            set composeField to value of e
            exit repeat
          end if
        end try
      end repeat
      return composeField
    end tell
  end tell
end tell
'

compose_after="$(osascript -e "$verify_sent")"
if [ "$compose_after" != "missing value" ] && [ -n "$compose_after" ]; then
  echo "send verification failed: compose field still populated: $compose_after" >&2
  exit 1
fi

echo "sent"
