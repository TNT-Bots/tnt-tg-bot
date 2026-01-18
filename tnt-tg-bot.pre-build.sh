#!/usr/bin/env bash

set -eu -o pipefail
# -e - Прекращает выполнение скрипта если команда завершилась ошибкой, выводит в stderr строку с ошибкой.
# -u - Прекращает выполнение скрипта, если встретилась несуществующая переменная.
# -o pipefail - Прекращает выполнение скрипта, даже если одна из частей пайпа завершилась ошибкой.

source "$(dirname "$0")/bin/lib/consts.sh"
source "$(dirname "$0")/bin/lib/customize.sh"
source "$(dirname "$0")/bin/lib/tools.sh"

echo "$(Cecho "  _________ _       _________  _________ _______    ______   _______ _________ ")"
echo "$(Cecho "  \__   __/( (    /|\__   __/  \__   __/(  ____ \  (  ___ \ (  ___  )\__   __/ ")"
echo "$(Cecho "     ) (   |  \  ( |   ) (        ) (   | (    \/  | (   ) )| (   ) |   ) (    ")"
echo "$(Cecho "     | |   |   \ | |   | |        | |   | |        | (__/ / | |   | |   | |    ")"
echo "$(Cecho "     | |   | (\ \) |   | |        | |   | | ____   |  __ (  | |   | |   | |    ")"
echo "$(Cecho "     | |   | )  \  |   | |        | |   | (___) |  | )___) )| (___) |   | |    ")"
echo "$(Cecho "     )_(   |/    )_)   )_(        )_(   (_______)  |/ \___/ (_______)   )_(    ")"
echo "> $(HighlightPink "By uriid1")"
echo "> $(HighlightPink "GitHub: https://github.com/uriid1/tnt-tg-bot")"
echo

readonly base_tools=(tarantool luarocks tt unzip git gcc)
readonly optional_tools=(ldoc luacheck curl luajit openssl)
errs=0

# Found base tools
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"
Yecho " Found base tools...       "
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"

tools::found_tool "tarantool" || exit 1
tools::found_tool "luarocks"  || exit 1
tools::found_tool "tt"        || exit 1
tools::found_tool "unzip"     || exit 1
tools::found_tool "git"       || exit 1
tools::found_tool "gcc"       || exit 1

# Found optional tools
echo
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"
Yecho " Found optional tools...   "
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"

tools::found_tool "ldoc"
tools::found_tool "luacheck"
tools::found_tool "curl"
tools::found_tool "luajit"
tools::found_tool "openssl"

echo
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"
Yecho " Install Rocks...          "
echo  "-=-=-=-=-=-=-=-=-=-=-=-=-=-"

# https://github.com/tarantool/http
tools::tt_install "http" "1.9.0"

# https://github.com/uriid1/lua-multipart-post
tools::luarocks_install "lua-multipart-post" "1.0-0"

# https://github.com/wahern/luaossl
CC="gcc -std=gnu99" \
  tools::luarocks_install "luaossl" "20250929-0"

# https://github.com/uriid1/pimp-lua
tools::luarocks_install "pimp" "2.1-2"
