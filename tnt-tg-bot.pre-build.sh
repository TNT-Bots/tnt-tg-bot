#!/usr/bin/env bash

# -e - прекращает выполнение скрипта если команда завершилась ошибкой, выводит в stderr строку с ошибкой.
# -u - прекращает выполнение скрипта, если встретилась несуществующая переменная.
# -o pipefail - прекращает выполнение скрипта, даже если одна из частей пайпа завершилась ошибкой.
set -eu -o pipefail

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

echo "> $(HighlightPink "By uriid1")"
echo "> $(HighlightPink "GitHub: https://github.com/uriid1/tnt-tg-bot")"
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
    echo "Not found: $(Recho ${tool})"

    errs=$((errs+1))
  else
    echo "Found: $(Gecho ${tool})"
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
    echo "Not found: $(Yecho ${tool})"
  else
    echo "Found: $(Gecho ${tool})"
  fi
done

echo
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"
Yecho " Install Rocks...          "
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"

# https://github.com/tarantool/http
install_tt "http" "1.9.0"

# github.com/uriid1/lua-multipart-post
install_luarocks "lua-multipart-post" "1.0-0"

# https://github.com/wahern/luaossl
CC="gcc -std=gnu99" install_luarocks "luaossl" "20250929-0"

# github.com/uriid1/pimp-lua
install_luarocks "pimp" "2.1-2"
