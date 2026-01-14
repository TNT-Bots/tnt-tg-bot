#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/scripts/lib/const.sh"
source "$(dirname "$0")/scripts/lib/customize.sh"
source "$(dirname "$0")/scripts/lib/tt-tools.sh"

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

printf "> " && HighlightPink "By uriid1"
printf "> " && HighlightPink "GitHub: https://github.com/uriid1/tnt-tg-bot"
echo

found_tool() {
  local tool_name=$1
  if [ "$(which -a "$tool_name" . 2>/dev/null)" ]; then
    return 1
  fi
  return 0
}

readonly base_tools=(tarantool luarocks tt unzip git gcc)
readonly optional_tools=(ldoc luacheck curl luajit openssl)
errs=0

# Found base tools
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"
Yecho " Found base tools...       "
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"

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
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"
Yecho " Found optional tools... "
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"

for ((i = 0; i < ${#optional_tools[*]}; ++i)); do
  tool="${optional_tools[$i]}"

  if found_tool "${tool}"; then
    Yecho "Not found: ${tool}"
  else
    Gecho "Found: ${tool}"
  fi
done

echo
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"
Yecho " Install Rocks...          "
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"

# https://github.com/tarantool/http
install_tt http 1.9.0

# github.com/uriid1/lua-multipart-post
install_luarocks lua-multipart-post 1.0-0

# https://github.com/wahern/luaossl
CC="gcc -std=gnu99" install_luarocks luaossl 20250929-0

# github.com/uriid1/pimp-lua
install_luarocks pimp 2.1-2
