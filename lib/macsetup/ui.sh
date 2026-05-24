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

uiRenderChoiceMenu() {
  local prompt="$1"
  local selected_index="$2"
  shift 2
  local options=("$@")
  local index=0
  local option=""

  printf '   => %s\n' "$prompt"
  for option in "${options[@]}"; do
    if [ "$index" -eq "$selected_index" ]; then
      printf '    %b>%b %b%s%b\n' "$BLUE" "$RESET_COLOR" "$GREEN" "$option" "$RESET_COLOR"
    else
      printf '      %s\n' "$option"
    fi
    index=$((index + 1))
  done
}

uiChooseInteractive() {
  local prompt="$1"
  local default_index="$2"
  shift 2
  local options=("$@")
  local option_count="${#options[@]}"
  local selected_index="$default_index"
  local fallback_index=""

  if [ "$option_count" -eq 0 ]; then
    return 1
  fi

  if [ "$selected_index" -lt 0 ] || [ "$selected_index" -ge "$option_count" ]; then
    selected_index=0
  fi

  fallback_index="$(uiFallbackIndex "${options[@]}")"

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

    uiEraseLines "$((option_count + 1))"
    uiRenderChoiceMenu "$prompt" "$selected_index" "${options[@]}"
  done

  uiEraseLines "$((option_count + 1))"
  uiSetChoice "$selected_index" "${options[@]}"
  printf '   => %s %b%s%b\n' "$prompt" "$GREEN" "$MACSETUP_UI_CHOICE" "$RESET_COLOR"
  echo
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
