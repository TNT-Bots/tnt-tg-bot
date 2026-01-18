# lib/customize.sh
#

[[ -n "${CUSTOMIZE_SH_LOADED:-}" ]] && return
readonly CUSTOMIZE_SH_LOADED=1

# Цветовые коды
readonly C_DEF='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_UNDERLINE='\033[4m'

readonly C_BLACK='\033[30m'
readonly C_RED='\033[31m'
readonly C_GREEN='\033[32m'
readonly C_YELLOW='\033[33m'
readonly C_BLUE='\033[34m'
readonly C_MAGENTA='\033[35m'
readonly C_CYAN='\033[36m'
readonly C_PINK='\033[95m'
readonly C_WHITE='\033[37m'

# Фоновые цвета
readonly BG_RED='\033[41m'
readonly BG_GREEN='\033[42m'
readonly BG_YELLOW='\033[43m'
readonly BG_BLUE='\033[44m'
readonly BG_MAGENTA='\033[45m'
readonly BG_CYAN='\033[46m'
readonly BG_WHITE='\033[47m'
readonly BG_BLACK='\033[40m'

Success() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_GREEN}$1${C_DEF}"
  fi
}

Failed() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_RED}$1${C_DEF}"
  fi
}

# Жёлтый
Yecho() {  
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_YELLOW}$1${C_DEF}"
  fi
}

# Красный
Recho() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_RED}$1${C_DEF}"
  fi
}

# Зелёный
Gecho() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_GREEN}$1${C_DEF}"
  fi
}

# Синий
Becho() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_BLUE}$1${C_DEF}"
  fi
}

# Циан
Cecho() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_CYAN}$1${C_DEF}"
  fi
}

# Магента
Mecho() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_MAGENTA}$1${C_DEF}"
  fi
}

# Жирный (акцент)
Bold() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_BOLD}$1${C_DEF}"
  fi
}

# Подчёркнутый текст
Uline() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${C_UNDERLINE}$1${C_DEF}"
  fi
}

# Выделение фоном (жёлтый фон + чёрный текст)
Highlight() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${BG_YELLOW}${C_BLACK}$1${C_DEF}"
  fi
}

# Выделение фоном (черный фон + розовый текст)
HighlightPink() {
  if [[ "$TERM" != *256color* ]]; then
    echo -e $1
  else
    echo -e "${BG_BLACK}${C_PINK}$1${C_DEF}"
  fi
}
