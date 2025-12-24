#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/scripts/lib/const.sh"
source "$(dirname "$0")/scripts/lib/customize.sh"

Cecho "
 _________ _       _________  _________ _______    ______   _______ _________
 \__   __/( (    /|\__   __/  \__   __/(  ____ \  (  ___ \ (  ___  )\__   __/
    ) (   |  \  ( |   ) (        ) (   | (    \/  | (   ) )| (   ) |   ) (
    | |   |   \ | |   | |        | |   | |        | (__/ / | |   | |   | |
    | |   | (\ \) |   | |        | |   | | ____   |  __ (  | |   | |   | |
    | |   | | \   |   | |        | |   | | \_  )  | (  \ \ | |   | |   | |
    | |   | )  \  |   | |        | |   | (___) |  | )___) )| (___) |   | |
    )_(   |/    )_)   )_(        )_(   (_______)  |/ \___/ (_______)   )_(
"

Uline "By uriid1"
Uline "GitHub: https://github.com/uriid1/tnt-tg-bot"
echo

found_tool() {
  local tool_name=$1
  if [ "$(which -a "$tool_name" . 2>/dev/null)" ]; then
    return 1
  fi
  return 0
}

readonly base_tools=(tarantool tt luarocks unzip git gcc)
readonly optional_tools=(ldoc luacheck curl luajit openssl)
errs=0

# Found base tools
echo "------------------------"
echo "Found base tools...     "
echo "------------------------"

for ((i = 0; i < ${#base_tools[*]}; ++i)); do
  tool="${base_tools[$i]}"

  if found_tool "${tool}"; then
    Recho "Not found: ${tool}"

    errs=$((errs+1))
  else
    Gecho "Found: ${tool}"
  fi
done

if [ $errs -ge 1 ]; then
  exit 1
fi

# Found optional tools
echo
echo "------------------------"
echo "Found optional tools... "
echo "------------------------"

for ((i = 0; i < ${#optional_tools[*]}; ++i)); do
  tool="${optional_tools[$i]}"

  if found_tool "${tool}"; then
    Yecho "Not found: ${tool}"
  else
    Gecho "Found: ${tool}"
  fi
done

# Install rocks
echo
echo "------------------------"
echo "Install Rocks...        "
echo "------------------------"

# https://github.com/tarantool/http
printf "Install: " && Gecho "http"
tt rocks install http

# github.com/uriid1/lua-multipart-post
printf "Install: " && Gecho "lua-multipart-post"
luarocks install --local \
  --tree=$PWD/.rocks \
  --lua-version 5.1 \
  lua-multipart-post

# https://github.com/wahern/luaossl
printf "Install: " && Gecho "luaossl"
CC="gcc -std=gnu99" luarocks install --local \
  --tree=$PWD/.rocks \
  --lua-version 5.1 \
  luaossl

# github.com/uriid1/pimp-lua
printf "Install: " && Gecho "pimp"
luarocks install --local \
  --tree=$PWD/.rocks \
  --lua-version 5.1 \
  pimp
