#!/usr/bin/env bash

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
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "[${C_GREEN}$1${C_DEF}]"
}

Failed() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "[${C_RED}$1${C_DEF}]"
}

# Жёлтый
Yecho() {  
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_YELLOW}$1${C_DEF}"
}

# Красный
Recho() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_RED}$1${C_DEF}"
}

# Зелёный
Gecho() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_GREEN}$1${C_DEF}"
}

# Синий
Becho() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_BLUE}$1${C_DEF}"
}

# Циан
Cecho() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_CYAN}$1${C_DEF}"
}

# Магента
Mecho() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_MAGENTA}$1${C_DEF}"
}

# Жирный (акцент)
Bold() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_BOLD}$1${C_DEF}"
}

# Подчёркнутый текст
Uline() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${C_UNDERLINE}$1${C_DEF}"
}

# Выделение фоном (жёлтый фон + чёрный текст)
Highlight() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${BG_YELLOW}${C_BLACK}$1${C_DEF}"
}

# Выделение фоном (черный фон + розовый текст)
HighlightPink() {
  [[ "$TERM" != *256color* ]] && echo -e $1

  echo -e "${BG_BLACK}${C_PINK}$1${C_DEF}"
}
