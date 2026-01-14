#!/usr/bin/env bash

# pipefail не совместим с grep -q, head, sed -n 1p без обработки SIGPIPE
# поэтому локально отключается

install_tt() {
  local rock="$1"
  local version="$2"

  set +o pipefail
  if tt rocks list --local --tree=$PWD/.rocks | grep -q "^[[:space:]]*${rock}[[:space:]]*"; then
    echo -e "[tt] Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  echo -e "[tt] Install: ${C_GREEN}${rock}${C_DEF}"

  tt rocks install \
    --local \
    --tree=$PWD/.rocks \
    ${rock} ${version}
}

install_luarocks() {
  local rock="$1"
  local version="$2"

  set +o pipefail
  if tt rocks list --local --tree=$PWD/.rocks | grep -q "^[[:space:]]*${rock}[[:space:]]*"; then
    echo -e "[tt] Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  if luarocks list --local --tree=$PWD/.rocks --lua-version 5.1 | grep -q "^[[:space:]]*${rock}[[:space:]]*"; then
    echo -e "[luarocks] Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  echo -e "[tt] Install: ${C_GREEN}${rock}${C_DEF}"

  tt rocks install \
    --server https://luarocks.org \
    --local \
    --tree=$PWD/.rocks \
    --lua-version 5.1 \
    ${rock} ${version}
}
