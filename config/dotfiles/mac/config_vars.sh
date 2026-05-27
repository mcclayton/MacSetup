# Disables PS1 Prompt and 'ls' command usage of nerd font icons
export DISABLE_NERD_FONT_ICONS="${DISABLE_NERD_FONT_ICONS:-false}"

# Codex shell does not support the Nerd Font icons, so force plain glyphs there.
case "${CODEX_SHELL:-}" in
  1|true|TRUE) export DISABLE_NERD_FONT_ICONS=true ;;
esac

# Shared prompt/statusline separators used when Nerd Font icons are disabled.
export PS1_PROMPT_PLAIN_SEPARATOR="${PS1_PROMPT_PLAIN_SEPARATOR:-}"
export PS1_PROMPT_PLAIN_RIGHT_SEPARATOR="${PS1_PROMPT_PLAIN_RIGHT_SEPARATOR:-}"
export PS1_PROMPT_PLAIN_ARROW="${PS1_PROMPT_PLAIN_ARROW:-↳}"
