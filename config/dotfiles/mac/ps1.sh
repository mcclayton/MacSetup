# Shared shell prompt renderer for bash and zsh.

ps1_prompt_palette() {
  PS1_PROMPT_YELLOW_RGB='238;212;159'
  PS1_PROMPT_PRIMARY_RGB='36;39;58'
  PS1_PROMPT_PATH_RGB='73;77;100'
  PS1_PROMPT_GIT_RGB='91;96;120'
  PS1_PROMPT_DARK_RGB='24;25;38'
  PS1_PROMPT_TEXT_RGB='202;211;245'
  PS1_PROMPT_PLAIN_SEPARATOR="${PS1_PROMPT_PLAIN_SEPARATOR:-⬤}"
  PS1_PROMPT_PLAIN_ARROW="${PS1_PROMPT_PLAIN_ARROW:-↳}"
}

ps1_prompt_git_branch_name() {
  git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

ps1_prompt_identity_label() {
  local shell="$1"
  local label="$2"

  case "$shell" in
    zsh)
      printf '%%B%s%%b' "$label"
      ;;
    bash)
      printf '\001\033[1m\002%s\001\033[22m\002' "$label"
      ;;
    *)
      printf '%s' "$label"
      ;;
  esac
}

ps1_prompt_default_identity() {
  whoami 2>/dev/null || printf 'user'
}

ps1_prompt_path_label() {
  case "$1" in
    zsh) printf '%%~' ;;
    bash) printf '\\w' ;;
  esac
}

ps1_prompt_reset() {
  case "$1" in
    zsh) printf '%%{\033[0m%%}' ;;
    bash) printf '\001\033[0m\002' ;;
  esac
}

ps1_prompt_fg() {
  local shell="$1"
  local rgb="$2"

  case "$shell" in
    zsh) printf '%%{\033[38;2;%sm%%}' "$rgb" ;;
    bash) printf '\001\033[38;2;%sm\002' "$rgb" ;;
  esac
}

ps1_prompt_fg_default_bg() {
  local shell="$1"
  local rgb="$2"

  case "$shell" in
    zsh) printf '%%{\033[38;2;%sm\033[49m%%}' "$rgb" ;;
    bash) printf '\001\033[38;2;%sm\033[49m\002' "$rgb" ;;
  esac
}

ps1_prompt_style() {
  local shell="$1"
  local fg_rgb="$2"
  local bg_rgb="$3"

  case "$shell" in
    zsh) printf '%%{\033[38;2;%s;48;2;%sm%%}' "$fg_rgb" "$bg_rgb" ;;
    bash) printf '\001\033[38;2;%s;48;2;%sm\002' "$fg_rgb" "$bg_rgb" ;;
  esac
}

ps1_prompt_segment_end() {
  local shell="$1"
  local bg_rgb="$2"
  local next_bg_rgb="${3:-}"

  if [ -n "$next_bg_rgb" ]; then
    printf '%s' "$(ps1_prompt_style "$shell" "$bg_rgb" "$next_bg_rgb")"
    printf ''
  else
    printf '%s' "$(ps1_prompt_fg "$shell" "$bg_rgb")"
    printf ''
  fi
  printf '%s' "$(ps1_prompt_reset "$shell")"
}

ps1_prompt_leading_badge() {
  local shell="$1"
  local label="$2"
  local bg_rgb="$3"
  local fg_rgb="${4:-$PS1_PROMPT_DARK_RGB}"
  local next_bg_rgb="${5:-}"

  if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
    printf '%s' "$label"
    return
  fi

  printf '%s %s ' "$(ps1_prompt_style "$shell" "$fg_rgb" "$bg_rgb")" "$label"
  printf '%s' "$(ps1_prompt_reset "$shell")"
  ps1_prompt_segment_end "$shell" "$bg_rgb" "$next_bg_rgb"
}

ps1_prompt_ascii_segment() {
  local shell="$1"
  local label="$2"
  local bg_rgb="$3"
  local fg_rgb="${4:-$PS1_PROMPT_TEXT_RGB}"
  local next_bg_rgb="${5:-}"

  printf '%s %s ' "$(ps1_prompt_style "$shell" "$fg_rgb" "$bg_rgb")" "$label"
  if [ -n "$next_bg_rgb" ]; then
    printf '%s%s' "$(ps1_prompt_style "$shell" "$bg_rgb" "$next_bg_rgb")" "$PS1_PROMPT_PLAIN_SEPARATOR"
  else
    printf '%s%s%s' \
      "$(ps1_prompt_fg_default_bg "$shell" "$bg_rgb")" \
      "$PS1_PROMPT_PLAIN_SEPARATOR" \
      "$(ps1_prompt_reset "$shell")"
  fi
}

ps1_prompt_git_badge_zsh() {
  local branch
  ps1_prompt_palette
  branch="$(ps1_prompt_git_branch_name)"
  [ -z "$branch" ] && return
  branch="${branch//\%/%%}"

  printf '%s' "$(ps1_prompt_leading_badge zsh " $branch" "$PS1_PROMPT_GIT_RGB" "$PS1_PROMPT_TEXT_RGB")"
}

ps1_prompt_git_badge_bash() {
  local branch
  ps1_prompt_palette
  branch="$(ps1_prompt_git_branch_name)"
  [ -z "$branch" ] && return

  printf '%s' "$(ps1_prompt_leading_badge bash " $branch" "$PS1_PROMPT_GIT_RGB" "$PS1_PROMPT_TEXT_RGB")"
}

ps1_prompt_plain_git_zsh() {
  local branch
  ps1_prompt_palette
  branch="$(ps1_prompt_git_branch_name)"
  [ -z "$branch" ] && return
  branch="${branch//\%/%%}"

  printf '%s' "$(ps1_prompt_ascii_segment zsh "$branch" "$PS1_PROMPT_GIT_RGB" "$PS1_PROMPT_TEXT_RGB")"
}

ps1_prompt_plain_git_bash() {
  local branch
  ps1_prompt_palette
  branch="$(ps1_prompt_git_branch_name)"
  [ -z "$branch" ] && return

  printf '%s' "$(ps1_prompt_ascii_segment bash "$branch" "$PS1_PROMPT_GIT_RGB" "$PS1_PROMPT_TEXT_RGB")"
}

ps1_prompt_git_command() {
  local shell="$1"
  local mode="$2"

  case "$shell:$mode" in
    zsh:plain) printf '$(ps1_prompt_plain_git_zsh)' ;;
    zsh:badge) printf '$(ps1_prompt_git_badge_zsh)' ;;
    bash:plain) printf '$(ps1_prompt_plain_git_bash)' ;;
    bash:badge) printf '$(ps1_prompt_git_badge_bash)' ;;
  esac
}

ps1_prompt_second_line() {
  local shell="$1"
  local arrow

  if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
    arrow="  $PS1_PROMPT_PLAIN_ARROW  "
  else
    arrow='  󱞩  '
  fi

  printf '%s%s$ %s' \
    "$(ps1_prompt_fg "$shell" "$PS1_PROMPT_YELLOW_RGB")" \
    "$arrow" \
    "$(ps1_prompt_reset "$shell")"
}

ps1_build_prompt_for_shell() {
  local shell="$1"
  local identity="${2:-}"
  local identity_label
  local path_label
  local line_1
  local line_2

  ps1_prompt_palette
  [ -n "$identity" ] || identity="$(ps1_prompt_default_identity)"
  identity_label="$(ps1_prompt_identity_label "$shell" "$identity")"
  path_label="$(ps1_prompt_path_label "$shell")"

  if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
    line_1="$(ps1_prompt_ascii_segment "$shell" "$identity_label" "$PS1_PROMPT_PRIMARY_RGB" "$PS1_PROMPT_TEXT_RGB" "$PS1_PROMPT_PATH_RGB")"
    line_1="$line_1$(ps1_prompt_ascii_segment "$shell" "$path_label" "$PS1_PROMPT_PATH_RGB" "$PS1_PROMPT_TEXT_RGB" "$PS1_PROMPT_GIT_RGB")"
    line_1="$line_1$(ps1_prompt_git_command "$shell" plain)"
  else
    line_1="$(ps1_prompt_leading_badge "$shell" "$identity_label" "$PS1_PROMPT_PRIMARY_RGB" "$PS1_PROMPT_TEXT_RGB" "$PS1_PROMPT_PATH_RGB")"
    line_1="$line_1$(ps1_prompt_leading_badge "$shell" " $path_label" "$PS1_PROMPT_PATH_RGB" "$PS1_PROMPT_TEXT_RGB" "$PS1_PROMPT_GIT_RGB")"
    line_1="$line_1$(ps1_prompt_git_command "$shell" badge)"
  fi

  line_2="$(ps1_prompt_second_line "$shell")"
  printf '%s\n%s' "$line_1" "$line_2"
}

build_ps1_prompt_zsh() {
  ps1_build_prompt_for_shell zsh "$1"
}

build_ps1_prompt_bash() {
  ps1_build_prompt_for_shell bash "$1"
}

build_ps1_prompt() {
  if [ -n "${ZSH_VERSION:-}" ]; then
    build_ps1_prompt_zsh "$@"
  elif [ -n "${BASH_VERSION:-}" ]; then
    build_ps1_prompt_bash "$@"
  fi
}
