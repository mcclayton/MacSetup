source ~/.config_vars
source ~/.utility_aliases
source ~/.splash_screens

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
    # Nix-prompt-inspired stacked badge prompt with a dark teal pill ramp and Catppuccin accents.
    PROMPT_RESET='\[\033[0m\]'
    PROMPT_FG_BLUE='\[\033[38;2;138;173;244m\]'
    PROMPT_FG_GREEN='\[\033[38;2;166;218;149m\]'
    PROMPT_FG_YELLOW='\[\033[38;2;238;212;159m\]'
    PROMPT_FG_TEXT='\[\033[38;2;202;211;245m\]'
    PROMPT_PRIMARY_RGB='36;39;58'
    PROMPT_PATH_RGB='73;77;100'
    PROMPT_GIT_RGB='91;96;120'
    PROMPT_DARK_RGB='24;25;38'
    PROMPT_PRIMARY_FG_RGB='202;211;245'
    PROMPT_LIGHT_RGB='202;211;245'
    INITIALS=$'\001\033[1m\002MCC\001\033[22m\002'

    prompt_badge_bash() {
      local label="$1"
      local bg_rgb="$2"
      local fg_rgb="${3:-$PROMPT_DARK_RGB}"

      if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
        printf '%s' "$label"
        return
      fi

      printf '\001\033[38;2;%sm\002' "$bg_rgb"
      printf '\001\033[38;2;%s;48;2;%sm\002 %s ' "$fg_rgb" "$bg_rgb" "$label"
      printf '\001\033[0m\002'
      printf '\001\033[38;2;%sm\002' "$bg_rgb"
      printf '\001\033[0m\002'
    }

    prompt_leading_badge_bash() {
      local label="$1"
      local bg_rgb="$2"
      local fg_rgb="${3:-$PROMPT_DARK_RGB}"
      local next_bg_rgb="${4:-}"

      if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
        printf '%s' "$label"
        return
      fi

      printf '\001\033[38;2;%s;48;2;%sm\002 %s ' "$fg_rgb" "$bg_rgb" "$label"
      printf '\001\033[0m\002'
      if [ -n "$next_bg_rgb" ]; then
        printf '\001\033[38;2;%s;48;2;%sm\002' "$bg_rgb" "$next_bg_rgb"
      else
        printf '\001\033[38;2;%sm\002' "$bg_rgb"
      fi
      printf '\001\033[0m\002'
    }

    prompt_git_branch_name() {
      git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
    }

    prompt_git_badge_bash() {
      local branch
      branch="$(prompt_git_branch_name)"
      [ -z "$branch" ] && return

      printf '%s' "$(prompt_leading_badge_bash " $branch" "$PROMPT_GIT_RGB" "$PROMPT_LIGHT_RGB")"
    }

    prompt_plain_git_bash() {
      local branch
      branch="$(prompt_git_branch_name)"
      [ -z "$branch" ] && return

      printf '%s' "$(prompt_ascii_segment_bash "$branch" "$PROMPT_GIT_RGB" "$PROMPT_LIGHT_RGB")"
    }

    prompt_ascii_segment_bash() {
      local label="$1"
      local bg_rgb="$2"
      local fg_rgb="${3:-$PROMPT_LIGHT_RGB}"
      local next_bg_rgb="${4:-}"

      printf '\001\033[38;2;%s;48;2;%sm\002 %s ' "$fg_rgb" "$bg_rgb" "$label"
      if [ -n "$next_bg_rgb" ]; then
        printf '\001\033[38;2;%s;48;2;%sm\002>' "$bg_rgb" "$next_bg_rgb"
      else
        printf '\001\033[0m\002'
      fi
    }

    if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
      PS1_LINE_1="$(prompt_ascii_segment_bash "$INITIALS" "$PROMPT_PRIMARY_RGB" "$PROMPT_PRIMARY_FG_RGB" "$PROMPT_PATH_RGB")$(prompt_ascii_segment_bash "\w" "$PROMPT_PATH_RGB" "$PROMPT_LIGHT_RGB" "$PROMPT_GIT_RGB")\$(prompt_plain_git_bash)"
      PS1_LINE_2="${PROMPT_FG_YELLOW}    $ $PROMPT_RESET"
    else
      PS1_LINE_1="$(prompt_leading_badge_bash "$INITIALS" "$PROMPT_PRIMARY_RGB" "$PROMPT_PRIMARY_FG_RGB" "$PROMPT_PATH_RGB")$(prompt_leading_badge_bash " \w" "$PROMPT_PATH_RGB" "$PROMPT_LIGHT_RGB" "$PROMPT_GIT_RGB")\$(prompt_git_badge_bash)"
      PS1_LINE_2="$PROMPT_FG_YELLOW  󱞩  $ $PROMPT_RESET"
    fi

    PS1="$PS1_LINE_1\n$PS1_LINE_2"
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
