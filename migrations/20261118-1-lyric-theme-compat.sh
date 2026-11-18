# shellcheck shell=bash
# Apps set up before Fluidity read ~/.config/lyric-theme (nvim, older configs). Once Fluidity owns the theme,
# point that old path at the Fluidity theme so they keep following it. Leaves a real folder alone.
if [[ -L $CONFIG/lyric-theme && -n ${FLUIDITY_TAKEOVER:-} ]]; then
  ln -sfn "$CONFIG/fluidity/theme" "$CONFIG/lyric-theme"
fi
