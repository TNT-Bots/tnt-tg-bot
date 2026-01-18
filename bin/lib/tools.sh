# lib/tools.sh
#
[[ -n "${TOOLS_SH_LOADED:-}" ]] && return
readonly TOOLS_SH_LOADED=1

__TOOLS_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

source "$__TOOLS_DIR/customize.sh"

# pipefail не совместим с grep -q, head, sed -n 1p без обработки SIGPIPE
# поэтому локально отключается

#
# Установка пакета через tt
# Аргументы:
#   rocks - имя рок пакета
#   version - версия
#
tools::tt_install() {
  local rock="$1"
  local version="$2"

  set +o pipefail

  if tt rocks list \
    --local \
    --tree=$PWD/.rocks \
    | grep -q "^[[:space:]]*${rock}[[:space:]]*";
  then
    echo -e "[tt] Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  echo -e "[tt] Install: ${C_GREEN}${rock}${C_DEF}"

  tt rocks install \
    --local \
    --tree=$PWD/.rocks \
    ${rock} ${version}
}

#
# Установка пакета через luarocks
# Аргументы:
#   rocks - имя рок пакета
#   version - версия
#
tools::luarocks_install() {
  local rock="$1"
  local version="$2"

  set +o pipefail

  if tt rocks list \
    --local \
    --tree=$PWD/.rocks \
    | grep -q "^[[:space:]]*${rock}[[:space:]]*";
  then
    echo -e "[tt] Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  if luarocks list \
    --local \
    --tree=$PWD/.rocks \
    --lua-version 5.1 \
    | grep -q "^[[:space:]]*${rock}[[:space:]]*";
  then
    echo -e "[luarocks] Already installed: ${C_GREEN}${rock}${C_DEF}"
    return 0
  fi

  echo -e "[tt] Install: ${C_GREEN}${rock}${C_DEF}"

  luarocks install \
    --server https://luarocks.org \
    --local \
    --tree=$PWD/.rocks \
    --lua-version 5.1 \
    ${rock} ${version}
}

#
# Поиск установленной утилиты
# Аргументы:
#   tool_name - имя утилиты
#
tools::found_tool() {
  local tool_name=$1

  if ! command -v "$tool_name" >/dev/null 2>&1; then
    echo "Not found: $(Recho "$tool_name")"
    return 1
  fi

  echo "Found: $(Gecho "$tool_name")"
  return 0
}
