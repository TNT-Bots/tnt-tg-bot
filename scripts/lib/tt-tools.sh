#!/usr/bin/env bash

#
# Install rocks
#
install_tt() {
  local rock="$1"
  local version="$2"

  if [[ -z $(tt rocks list --local --tree=$PWD/.rocks | grep -q "^${rock}") ]]; then
    echo -e "Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  echo -e "Install: ${C_GREEN}${rock}${C_DEF}"

  tt rocks install \
    --local \
    --tree=$PWD/.rocks \
    ${rock} ${version}
}

install_luarocks() {
  local rock="$1"
  local version="$2"

  if [[ -z $(luarocks list --local --tree=$PWD/.rocks | grep -q "^${rock}") ]]; then
    echo -e "Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  echo -e "Install: ${C_GREEN}${rock}${C_DEF}"

  tt rocks install \
    --server https://luarocks.org \
    --local \
    --tree=$PWD/.rocks \
    --lua-version 5.1 \
    ${rock} ${version}
}
