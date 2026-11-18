# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
sandbox
export FLUIDITY_LAYOUTS=$SANDBOX/layouts.json
echo '{"duo":[{"class":"calendio","cmd":"calendio"},{"class":"ghostty","cmd":"ghostty"}]}' >"$FLUIDITY_LAYOUTS"
# hyprctl: workspace 4 is active; calendio is open on workspace 1, ghostty isn't open
cat >"$SANDBOX/stubs/hyprctl" <<STUB
#!/usr/bin/env bash
echo "hyprctl \$*" >> "$LOG"
case "\$*" in
  "activeworkspace -j") echo '{"id":4}' ;;
  "clients -j") echo '[{"class":"calendio","address":"0xaa","workspace":{"id":1}}]' ;;
esac
STUB
printf '#!/usr/bin/env bash\necho "uwsm-app $*" >> %q\n' "$LOG" >"$SANDBOX/stubs/uwsm-app"; chmod +x "$SANDBOX/stubs/"*
t() { if "$@"; then ok "$name"; else fail "$name" "$(calls | paste -sd';')"; fi; }
FLUIDITY_LAYOUT_WAIT=0 fluidity-layout duo >/dev/null
name="an open app is pulled onto this workspace"; t called 'hl.dsp.window.move({ window = "address:0xaa", workspace = "4", follow = false })'
name="a closed app is launched"; t called "uwsm-app -- ghostty"
eq "list shows the layouts" "duo" "$(fluidity-layout list)"
status "an unknown layout fails" 1 fluidity-layout nope
done_testing
