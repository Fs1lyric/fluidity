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

# stats: day, week, month and year totals for the Screen Time app
rm -f "$d"/*.tsv
put() { local day=$1 hhmm=$2 n=$3 app=$4 t i; t=$(date -d "$day $hhmm" +%s)
  for ((i = 0; i < n; i++)); do printf '%s\t%s\n' $((t + i * 60)) "$app"; done >>"$d/$day.tsv"; }
put 2026-11-16 09:00 10 zen
put 2026-11-18 14:00 20 com.mitchellh.ghostty
put 2026-11-23 08:00 5 zen
put 2026-11-09 10:00 4 zen
put 2026-10-05 20:00 7 calendio
put 2025-12-31 23:00 3 zen
w=$(fluidity-wellbeing stats week 2026-11-18)
eq "week runs Monday to Sunday" "2026-11-16 2026-11-22" "$(jq -r '"\(.start) \(.end)"' <<<"$w")"
eq "week total" 30 "$(jq .total <<<"$w")"
eq "week top app" "ghostty 20" "$(jq -r '.apps[0] | "\(.app) \(.minutes)"' <<<"$w")"
eq "week bars by day" "7 10 20" "$(jq -r '"\(.bars | length) \(.bars[0]) \(.bars[2])"' <<<"$w")"
eq "week vs last week" 4 "$(jq .prev <<<"$w")"
eq "week daily average over active days" "2 15" "$(jq -r '"\(.days) \(.avg)"' <<<"$w")"
j=$(fluidity-wellbeing stats day 2026-11-18)
eq "day bars by hour" "24 20 20" "$(jq -r '"\(.bars | length) \(.bars[14]) \(.total)"' <<<"$j")"
eq "day vs yesterday" 0 "$(jq .prev <<<"$j")"
j=$(fluidity-wellbeing stats month 2026-11-10)
eq "month total and range" "39 2026-11-01 2026-11-30" "$(jq -r '"\(.total) \(.start) \(.end)"' <<<"$j")"
eq "month bars by date" "30 10" "$(jq -r '"\(.bars | length) \(.bars[15])"' <<<"$j")"
eq "month vs last month" 7 "$(jq .prev <<<"$j")"
j=$(fluidity-wellbeing stats year 2026-06-01)
eq "year total" 46 "$(jq .total <<<"$j")"
eq "year bars by month" "12 7 39" "$(jq -r '"\(.bars | length) \(.bars[9]) \(.bars[10])"' <<<"$j")"
eq "year vs last year" 3 "$(jq .prev <<<"$j")"
eq "an empty week" "0 7" "$(fluidity-wellbeing stats week 2001-01-03 | jq -r '"\(.total) \(.bars | length)"')"
fluidity-wellbeing stats fortnight >/dev/null 2>&1
eq "unknown period fails" 2 "$?"

# app: opens the Screen Time window, or focuses it when it's already open
printf '#!/usr/bin/env bash\nexit 1\n' >"$SANDBOX/stubs/pgrep"
: >"$LOG"; fluidity-wellbeing app
has "app launches the screentime shell" "qs -n -c screentime" "$(calls)"
done_testing
