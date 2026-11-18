# shellcheck shell=bash
step "packages"
if [[ -n ${FLUIDITY_SKIP_PACKAGES:-} ]]; then echo "  skipped"; else
  mapfile -t pkgs < <(sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//; /^$/d' "$ROOT/install/packages.txt")
  FLUIDITY_TTY=1 "$ROOT/bin/fluidity-install" "${pkgs[@]}" || return 1
fi
