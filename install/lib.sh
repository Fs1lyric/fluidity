# shellcheck shell=bash
# helpers for the install steps (sourced)

# back up a real file before Fluidity replaces it
backup() {
  local f=$1 rel
  [[ -e $f && ! -L $f ]] || return 0
  rel=${f#"$HOME"/}
  mkdir -p "$BACKUP/$(dirname "$rel")"
  cp -a "$f" "$BACKUP/$rel"
}
# place a starter file once; after that it is yours and is never touched again
place() { # SRC DST
  local src=$1 dst=$2
  grep -qxF "$dst" "$MANIFEST" && return 0
  if [[ -e $dst ]] && cmp -s "$src" "$dst"; then echo "$dst" >>"$MANIFEST"; return 0; fi
  backup "$dst"; rm -f "$dst"
  mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"
  echo "$dst" >>"$MANIFEST"
}
# a link Fluidity owns (re-pointed on every run)
own_link() { # TARGET LINK
  local target=$1 l=$2
  [[ -L $l && $(readlink "$l") == "$target" ]] && return 0
  backup "$l"; rm -rf "$l"
  mkdir -p "$(dirname "$l")"; ln -s "$target" "$l"
}
