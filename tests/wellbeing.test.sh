# shellcheck shell=bash
# Screen time: one sample a minute of the focused app; today's totals as JSON; a break nudge after 50 min straight.
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
sandbox
d=$FLUIDITY_STATE/wellbeing; mkdir -p "$d"
day=$(date +%F); t0=$(date -d "$day 09:00" +%s)
{ for i in $(seq 0 29); do printf '%s\tzen\n' $((t0 + i * 60)); done
  for i in $(seq 30 39); do printf '%s\tcom.mitchellh.ghostty\n' $((t0 + i * 60)); done
  printf '%s\tcalendio\n' $((t0 + 3 * 3600)); } >"$d/$day.tsv"
j=$(fluidity-wellbeing today)
eq "total minutes" 41 "$(jq .total <<<"$j")"
eq "top app first" "zen 30" "$(jq -r '.apps[0] | "\(.app) \(.minutes)"' <<<"$j")"
eq "class tidied to a name" "ghostty" "$(jq -r '.apps[1].app' <<<"$j")"
eq "hour buckets" "40 1" "$(jq -r '"\(.hours[9]) \(.hours[12])"' <<<"$j")"
eq "an empty day" 0 "$(fluidity-wellbeing today 2001-01-01 | jq .total)"

# tick: records the focused window's class, skips while locked
printf '#!/usr/bin/env bash\n[[ $* == *activewindow* ]] && echo %q\n' '{"class":"obsidian"}' >"$SANDBOX/stubs/hyprctl"; chmod +x "$SANDBOX/stubs/hyprctl"
rm -f "$d/$day.tsv"; fluidity-wellbeing tick
has "tick records the app" "obsidian" "$(cat "$d/$day.tsv" 2>/dev/null)"
printf '#!/usr/bin/env bash\nexit 0\n' >"$SANDBOX/stubs/pgrep"
fluidity-wellbeing tick
eq "no sample while locked" 1 "$(wc -l <"$d/$day.tsv")"

# break nudge: 50 straight minutes, then quiet for 50 more
now=$(date +%s); : >"$d/$day.tsv"
for i in $(seq 50 -1 0); do printf '%s\tzen\n' $((now - i * 60)) >>"$d/$day.tsv"; done
: >"$LOG"; fluidity-wellbeing nudge
name="nudges after 50 min"; called "notify-send" && ok "$name" || fail "$name" "$(calls)"
: >"$LOG"; fluidity-wellbeing nudge
name="not again right away"; called "notify-send" && fail "$name" || ok "$name"
done_testing
