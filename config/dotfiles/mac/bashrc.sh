[ -f ~/.shell_common ] && source ~/.shell_common

# This file is processed on each interactive invocation of bash

clearTerminal() {
  if command -v clear >/dev/null 2>&1 && clear 2>/dev/null; then
    return 0
  fi

  if [ -n "${TERM:-}" ] && [ "$TERM" != "dumb" ]; then
    printf '\033[H\033[2J'
  fi
}

# Avoid problems with scp -- don't process the rest of the file if non-interactive
[[ $- != *i* ]] && return

# Custom binding Overrides to use Ctrl+WASD to move around the terminal line
bind '"\C-a": backward-word'
bind '"\C-d": forward-word' # Note Ctrl+D is EOF, so this is a bit of a misnomer to override
bind '"\C-s": beginning-of-line'
bind '"\C-w": end-of-line'

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
  if [ "$TERM" != "dumb" ] && type build_ps1_prompt >/dev/null 2>&1; then
    PS1="$(build_ps1_prompt MCC)"
  fi
fi

splash_screen() {
  clearTerminal
  local SPLASH_COMMAND=
  if type $SPLASH_COMMAND >/dev/null; then
    $SPLASH_COMMAND
  fi
}

# Invoke splash screen
splash_screen
