# Shared shell startup used by both bash and zsh.

[ -f ~/.config_vars ] && source ~/.config_vars
[ -f ~/.utility_aliases ] && source ~/.utility_aliases
[ -f ~/.splash_screens ] && source ~/.splash_screens
[ -f ~/.ps1 ] && source ~/.ps1

shellCommonCommandExists() {
  command -v "$1" >/dev/null 2>&1
}

shellCommonPrependPath() {
  local path_entry="$1"

  [ -n "$path_entry" ] || return 0
  case ":$PATH:" in
    *":$path_entry:"*) ;;
    *) export PATH="$path_entry:$PATH" ;;
  esac
}

shellCommonPrependPath "/usr/local/sbin"
shellCommonPrependPath "/usr/local/bin"

if [[ -n ${SSH_CONNECTION:-} ]]; then
  export EDITOR='vim'
elif shellCommonCommandExists code; then
  export EDITOR='code'
else
  export EDITOR='vim'
fi
