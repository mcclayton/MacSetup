#!/bin/bash

###########################
# Terminal UI Primitives  #
###########################

if [ -n "${MACSETUP_UI_LOADED:-}" ]; then
  return 0
fi

MACSETUP_UI_LOADED=true
MACSETUP_UI_CHOICE=""
MACSETUP_UI_INDEX=""
MACSETUP_UI_KEY=""

uiVisibleLength() {
  local text="$1"
  local esc=$'\033'

  text="$(printf '%s' "$text" | sed "s/${esc}(B//g; s/${esc}\\[[0-9;]*[[:alpha:]]//g")"
  echo "${#text}"
}

uiRepeat() {
  local char="$1"
  local count="$2"
  local output=""

  while [ "$count" -gt 0 ]; do
    output="${output}${char}"
    count=$((count - 1))
  done

  printf '%s' "$output"
}

uiPadRight() {
  local text="$1"
  local width="$2"
  local length=0
  local padding=0

  length="$(uiVisibleLength "$text")"
  padding=$((width - length))
  printf '%s' "$text"

  if [ "$padding" -gt 0 ]; then
    uiRepeat " " "$padding"
  fi
}

uiSupportsRoundedBoxes() {
  local charmap=""

  if [ "${MACSETUP_UI_ASCII:-}" = "true" ]; then
    return 1
  fi

  case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
    *UTF-8*|*utf-8*)
      return 0
      ;;
  esac

  if command -v locale >/dev/null 2>&1; then
    charmap="$(locale charmap 2>/dev/null || true)"
    case "$charmap" in
      *UTF-8*|*utf-8*|UTF8|utf8)
        return 0
        ;;
    esac
  fi

  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    return 0
  fi

  return 1
}

uiSetBoxChars() {
  if uiSupportsRoundedBoxes; then
    MACSETUP_UI_BOX_STYLE="rounded"
    MACSETUP_UI_BOX_TL="╭"
    MACSETUP_UI_BOX_TR="╮"
    MACSETUP_UI_BOX_BL="╰"
    MACSETUP_UI_BOX_BR="╯"
    MACSETUP_UI_BOX_H="─"
    MACSETUP_UI_BOX_V="│"
  else
    MACSETUP_UI_BOX_STYLE="ascii"
    MACSETUP_UI_BOX_TL="+"
    MACSETUP_UI_BOX_TR="+"
    MACSETUP_UI_BOX_BL="+"
    MACSETUP_UI_BOX_BR="+"
    MACSETUP_UI_BOX_H="-"
    MACSETUP_UI_BOX_V="|"
  fi
}

uiIsInteractive() {
  if [ "${MACSETUP_UI:-}" = "plain" ]; then
    return 1
  fi

  [ -t 0 ] && [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ]
}

uiHideCursor() {
  printf '\033[?25l'
}

uiShowCursor() {
  printf '\033[?25h'
}

uiEraseLines() {
  local count="$1"
  while [ "$count" -gt 0 ]; do
    printf '\033[1A\r\033[K'
    count=$((count - 1))
  done
}

uiReadKey() {
  local key=""
  local rest=""

  if ! IFS= read -rsn1 key; then
    return 1
  fi

  if [ "$key" = $'\033' ]; then
    IFS= read -rsn2 -t 1 rest || rest=""
    key="$key$rest"
  fi

  MACSETUP_UI_KEY="$key"
  return 0
}

uiFallbackIndex() {
  local index=0
  local option=""

  for option in "$@"; do
    case "$option" in
      "No"|"Skip"|"Cancel"|"Back"|"Quit"|"Cancel / Keep Current Default")
        echo "$index"
        return
        ;;
    esac
    index=$((index + 1))
  done

  echo "$(($# - 1))"
}

uiSetChoice() {
  local index="$1"
  shift
  local options=("$@")

  MACSETUP_UI_INDEX="$index"
  MACSETUP_UI_CHOICE="${options[$index]}"
  REPLY="$((index + 1))"
}

uiMenuTitle() {
  echo "${MACSETUP_UI_TITLE:-$1}"
}

uiMenuShowsPromptLine() {
  local prompt="$1"
  local title=""

  title="$(uiMenuTitle "$prompt")"
  [ "$title" != "$prompt" ]
}

uiMenuContentWidth() {
  local prompt="$1"
  shift
  local options=("$@")
  local title=""
  local footer="${MACSETUP_UI_FOOTER:-}"
  local width=28
  local length=0
  local option=""

  title="$(uiMenuTitle "$prompt")"

  length="$(uiVisibleLength "$title")"
  if [ "$((length + 1))" -gt "$width" ]; then
    width=$((length + 1))
  fi

  if uiMenuShowsPromptLine "$prompt"; then
    length="$(uiVisibleLength "$prompt")"
    if [ "$length" -gt "$width" ]; then
      width="$length"
    fi
  fi

  for option in "${options[@]}"; do
    length="$(uiVisibleLength "$option")"
    if [ "$((length + 3))" -gt "$width" ]; then
      width=$((length + 3))
    fi
  done

  if [ -n "$footer" ]; then
    length="$(uiVisibleLength "$footer")"
    if [ "$((length + 2))" -gt "$width" ]; then
      width=$((length + 2))
    fi
  fi

  echo "$width"
}

uiMenuLineCount() {
  local prompt="$1"
  local option_count="$2"
  local count=0

  count=$((option_count + 2))

  if uiMenuShowsPromptLine "$prompt"; then
    count=$((count + 2))
  fi

  uiSetBoxChars
  if [ "$MACSETUP_UI_BOX_STYLE" = "ascii" ]; then
    count=$((count + 1))
    if [ -n "${MACSETUP_UI_FOOTER:-}" ]; then
      count=$((count + 1))
    fi
  fi

  echo "$count"
}

uiPrintBoxTop() {
  local title="$1"
  local content_width="$2"
  local title_width=0
  local fill_width=0

  if [ "$MACSETUP_UI_BOX_STYLE" = "ascii" ]; then
    printf '%s' "$MACSETUP_UI_BOX_TL"
    uiRepeat "$MACSETUP_UI_BOX_H" "$((content_width + 2))"
    printf '%s\n' "$MACSETUP_UI_BOX_TR"
    uiPrintBoxLine "$title" "$content_width"
    return
  fi

  title_width="$(uiVisibleLength "$title")"
  fill_width=$((content_width - title_width - 1))

  printf '%s%s %s ' "$MACSETUP_UI_BOX_TL" "$MACSETUP_UI_BOX_H" "$title"
  if [ "$fill_width" -gt 0 ]; then
    uiRepeat "$MACSETUP_UI_BOX_H" "$fill_width"
  fi
  printf '%s\n' "$MACSETUP_UI_BOX_TR"
}

uiPrintBoxLine() {
  local content="$1"
  local content_width="$2"

  printf '%s ' "$MACSETUP_UI_BOX_V"
  uiPadRight "$content" "$content_width"
  printf ' %s\n' "$MACSETUP_UI_BOX_V"
}

uiPrintBoxFooterLine() {
  local footer="$1"
  local content_width="$2"
  local footer_width=0
  local padding=0

  footer_width="$(uiVisibleLength "$footer")"
  padding=$((content_width - footer_width))

  printf '%s ' "$MACSETUP_UI_BOX_V"
  if [ "$padding" -gt 0 ]; then
    uiRepeat " " "$padding"
  fi
  printf '%s %s\n' "$footer" "$MACSETUP_UI_BOX_V"
}

uiPrintBoxBottom() {
  local content_width="$1"
  local footer="${MACSETUP_UI_FOOTER:-}"
  local footer_width=0
  local fill_width=0

  if [ "$MACSETUP_UI_BOX_STYLE" = "ascii" ]; then
    if [ -n "$footer" ]; then
      uiPrintBoxFooterLine "$footer" "$content_width"
    fi

    printf '%s' "$MACSETUP_UI_BOX_BL"
    uiRepeat "$MACSETUP_UI_BOX_H" "$((content_width + 2))"
    printf '%s\n' "$MACSETUP_UI_BOX_BR"
    return
  fi

  if [ -z "$footer" ]; then
    printf '%s' "$MACSETUP_UI_BOX_BL"
    uiRepeat "$MACSETUP_UI_BOX_H" "$((content_width + 2))"
    printf '%s\n' "$MACSETUP_UI_BOX_BR"
    return
  fi

  footer_width="$(uiVisibleLength "$footer")"
  fill_width=$((content_width - footer_width))

  printf '%s%s %s ' "$MACSETUP_UI_BOX_BL" "$MACSETUP_UI_BOX_H" "$footer"
  if [ "$fill_width" -gt 0 ]; then
    uiRepeat "$MACSETUP_UI_BOX_H" "$fill_width"
  fi
  printf '%s\n' "$MACSETUP_UI_BOX_BR"
}

uiRenderChoiceMenu() {
  local prompt="$1"
  local selected_index="$2"
  shift 2
  local options=("$@")
  local title=""
  local content_width=0
  local index=0
  local option=""
  local option_line=""

  uiSetBoxChars
  title="$(uiMenuTitle "$prompt")"
  content_width="$(uiMenuContentWidth "$prompt" "${options[@]}")"

  uiPrintBoxTop "$title" "$content_width"

  if uiMenuShowsPromptLine "$prompt"; then
    uiPrintBoxLine "$prompt" "$content_width"
    uiPrintBoxLine "" "$content_width"
  fi

  for option in "${options[@]}"; do
    if [ "$index" -eq "$selected_index" ]; then
      option_line=" > ${GREEN}${option}${RESET_COLOR}"
    else
      option_line="   ${option}"
    fi
    uiPrintBoxLine "$option_line" "$content_width"
    index=$((index + 1))
  done

  uiPrintBoxBottom "$content_width"
}

uiPrintSelectedChoice() {
  local prompt="$1"
  local title=""

  title="$(uiMenuTitle "$prompt")"

  if [ "$title" != "$prompt" ]; then
    printf '%b%s%b: %b%s%b\n' "$ORANGE" "$title" "$RESET_COLOR" "$GREEN" "$MACSETUP_UI_CHOICE" "$RESET_COLOR"
  else
    printf '%s %b%s%b\n' "$prompt" "$GREEN" "$MACSETUP_UI_CHOICE" "$RESET_COLOR"
  fi
  echo
}

uiChooseInteractive() {
  local prompt="$1"
  local default_index="$2"
  shift 2
  local options=("$@")
  local option_count="${#options[@]}"
  local selected_index="$default_index"
  local fallback_index=""
  local line_count=0

  if [ "$option_count" -eq 0 ]; then
    return 1
  fi

  if [ "$selected_index" -lt 0 ] || [ "$selected_index" -ge "$option_count" ]; then
    selected_index=0
  fi

  fallback_index="$(uiFallbackIndex "${options[@]}")"
  line_count="$(uiMenuLineCount "$prompt" "$option_count")"

  uiHideCursor
  uiRenderChoiceMenu "$prompt" "$selected_index" "${options[@]}"

  while true; do
    if ! uiReadKey; then
      uiShowCursor
      return 130
    fi

    case "$MACSETUP_UI_KEY" in
      $'\033[A'|k|K)
        selected_index=$((selected_index - 1))
        if [ "$selected_index" -lt 0 ]; then
          selected_index=$((option_count - 1))
        fi
        ;;
      $'\033[B'|j|J)
        selected_index=$((selected_index + 1))
        if [ "$selected_index" -ge "$option_count" ]; then
          selected_index=0
        fi
        ;;
      ""|" ")
        break
        ;;
      q|Q|$'\033')
        selected_index="$fallback_index"
        break
        ;;
    esac

    uiEraseLines "$line_count"
    uiRenderChoiceMenu "$prompt" "$selected_index" "${options[@]}"
  done

  uiEraseLines "$line_count"
  uiSetChoice "$selected_index" "${options[@]}"
  uiPrintSelectedChoice "$prompt"
  uiShowCursor
  return 0
}

uiChoosePlain() {
  local prompt="$1"
  local default_index="$2"
  shift 2
  local options=("$@")
  local option_count="${#options[@]}"
  local index=0

  if [ "$option_count" -eq 0 ]; then
    return 1
  fi

  for index in "${!options[@]}"; do
    printf '%s) %s\n' "$((index + 1))" "${options[$index]}"
  done

  printf '   => %s ' "$prompt"
  if ! IFS= read -r REPLY; then
    return 2
  fi
  echo

  if [ -z "$REPLY" ]; then
    uiSetChoice "$default_index" "${options[@]}"
    return 0
  fi

  if [ "$option_count" -eq 2 ] && [ "${options[0]}" = "Yes" ] && [ "${options[1]}" = "No" ]; then
    case "$REPLY" in
      [Yy]*)
        uiSetChoice 0 "${options[@]}"
        return 0
        ;;
      [Nn]*|q|Q)
        uiSetChoice 1 "${options[@]}"
        return 0
        ;;
    esac
  fi

  case "$REPLY" in
    *[!0-9]*|"")
      return 1
      ;;
  esac

  index=$((REPLY - 1))
  if [ "$index" -lt 0 ] || [ "$index" -ge "$option_count" ]; then
    return 1
  fi

  uiSetChoice "$index" "${options[@]}"
  return 0
}

chooseOption() {
  local prompt="$1"
  shift
  local options=("$@")
  local default_index="${MACSETUP_UI_DEFAULT_INDEX:-0}"
  local status=0
  local fallback_index=""

  while true; do
    if uiIsInteractive; then
      uiChooseInteractive "$prompt" "$default_index" "${options[@]}"
    else
      uiChoosePlain "$prompt" "$default_index" "${options[@]}"
    fi
    status="$?"

    if [ "$status" -eq 0 ]; then
      return 0
    fi

    if [ "$status" -eq 2 ]; then
      fallback_index="$(uiFallbackIndex "${options[@]}")"
      uiSetChoice "$fallback_index" "${options[@]}"
      echo
      return 0
    fi

    if [ "$status" -eq 130 ]; then
      return 130
    fi

    warn "Invalid option $REPLY"
  done
}
