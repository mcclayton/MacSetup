source ~/.config_vars
source ~/.utility_aliases
source ~/.splash_screens

# This file is processed on each interactive invocation of bash

# Custom binding Overrides to use Ctrl+WASD to move around the terminal line
if [ -n "${BASH_VERSION:-}" ]; then
  bind '"\C-a": backward-word'
  bind '"\C-d": forward-word' # Note Ctrl+D is EOF, so this is a bit of a misnomer to override
  bind '"\C-s": beginning-of-line'
  bind '"\C-w": end-of-line'
fi

# Avoid problems with scp -- don't process the rest of the file if non-interactive
[[ $- != *i* ]] && return

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  if cmdExists code; then
    export EDITOR='code'
  else
    export EDITOR='vim'
  fi
fi

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

if cmdExists shopt; then
  # Append to the history file, don't overwrite it
  shopt -s histappend

  # Check the window size after each command and, if necessary,
  # Update the values of LINES and COLUMNS.
  shopt -s checkwinsize
fi

# Git branch in prompt.
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Show trailing slashes for directories
alias ls='ls -F'

# Some more ls aliases
alias ll='ls -l'
alias la='ls -A'


# Enable programmable completion features (you don't need to enable
# This, if it's already enabled in /etc/bash.bashrc and /etc/profile
# Sources /etc/bash.bashrc).
if cmdExists shopt; then
  if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
  fi
fi
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Set autocompletion to ignore case
set completion-ignore-case on

# Set default mail service
alias mail=mailx

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Source fzf for current shell
if [[ $(echo $BASH_VERSION) ]]; then
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  # Set the prompt
  if [ "$TERM" != "dumb" ]; then
    # Nice pretty color prompt with the current host and our current directory
    RED='\[\033[01;31m\]'; GRAY='\[\033[01;30m\]'; BLUE='\[\033[01;34m\]'; GREEN='\[\033[01;32m\]'
    INITIALS='MCC'
    BOLT='\342\232\241' # Lightning Bolt Emoji UTF-8
    ARROW_SEPARATOR='      ↳'
    HEARTS="$RED   "
    HEARTS_ARROW_SEPARATOR='        ↳'

    if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
      PS1_LINE_1="$BOLT  $GRAY$INITIALS:$BLUE\w$RED\$(parse_git_branch)"
      PS1_LINE_2="$GRAY$ARROW_SEPARATOR$GREEN  $ \[\e[0m\]"
    else
      PS1_LINE_1="$HEARTS  $GRAY$INITIALS:$BLUE%~$RED\$(parse_git_branch)"
      PS1_LINE_2="$GRAY$HEARTS_ARROW_SEPARATOR$GREEN  $ \[\e[0m\]"
    fi

    PS1="$PS1_LINE_1\n$PS1_LINE_2"
  fi
fi

splashClearScreen() {
  if command -v clear >/dev/null 2>&1; then
    if clear 2>/dev/null; then
      return
    fi

    case "${TERM:-}" in
      xterm-ghostty|ghostty)
        if TERM=xterm-256color clear 2>/dev/null; then
          return
        fi
        ;;
    esac
  fi

  printf '\033[H\033[2J'
}

splash_screen() {
  splashClearScreen
  local SPLASH_COMMAND=
  if [ -n "$SPLASH_COMMAND" ] && type "$SPLASH_COMMAND" >/dev/null 2>&1; then
    "$SPLASH_COMMAND"
  fi
}

# Invoke splash screen
splash_screen
