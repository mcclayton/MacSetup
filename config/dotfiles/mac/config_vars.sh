# Disables PS1 Prompt and 'ls' command usage of nerd font icons
DISABLE_NERD_FONT_ICONS=false

macsetupUseFallbackTerminfo() {
  case "${TERM:-}" in
    xterm-ghostty|ghostty)
      if command -v tput >/dev/null 2>&1 && ! tput cols >/dev/null 2>&1; then
        TERM=xterm-256color
        export TERM
      fi
      ;;
  esac
}

macsetupUseFallbackTerminfo
