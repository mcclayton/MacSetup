source ./.utility_aliases

# This file is processed on each interactive invocation of bash

# Avoid problems with scp -- don't process the rest of the file if non-interactive
[[ $- != *i* ]] && return

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary,
# Update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Git branch in prompt.
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Enable color support, should work with all modern terminals
if [ "$TERM" != "dumb" ]; then
	# Nice pretty color prompt with the current host and our current directory
  INITIALS='MCC'
  BOLT='⚡️'
  RED='\[\033[01;31m\]'; GRAY='\[\033[01;30m\]'; BLUE='\[\033[01;34m\]'; GREEN='\[\033[01;32m\]'
  PS1="$BOLT  $GRAY$INITIALS:$BLUE\w$RED\$(parse_git_branch) $GREEN$ \[\e[0m\]"
fi

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

# Some more ls aliases
alias ll='ls -l'
alias la='ls -A'


# Enable programmable completion features (you don't need to enable
# This, if it's already enabled in /etc/bash.bashrc and /etc/profile
# Sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# Set autocompletion to ignore case
set completion-ignore-case on

# Set default mail service
alias mail=mailx

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Define an alias for a welcome splash screen
welcome() {
  clear
  echo "   __ _  ________    "
  echo "  /  ' \/ __/ __/___ "
  echo " / /_/_/\__/\______/ "
  echo "/_/ Michael Clayton  "
  echo "-------------------->"
  echo ""
}

#Display text in rainbow if lolcat installed, else regular text
rainbowtext() {
  if hash lolcat 2>/dev/null; then
    printf "$1" | lolcat
  else
    printf "$1"
  fi
}

# Define an alias for a horse wearing a party hat. Why not?
partyhorse() {
  clear
  ph="                      .                                          \n"
  ph="$ph                     /|                                       \n"
  ph="$ph                    /_|                                       \n"
  ph="$ph               ,   /__|                                       \n"
  ph="$ph              / \,,___:\'|                                    \n"
  ph="$ph           ,{{| /}}}}/_.'                                     \n"
  ph="$ph          }}}}\` \'{{\'  \'.                                  \n"
  ph="$ph        {{{{{    _   ;, \                                     \n"
  ph="$ph     ,}}}}}}    /o\`\  \` ;)                                  \n"
  ph="$ph    {{{{{{   /           (                                    \n"
  ph="$ph    }}}}}}   |            \       _______________________     \n"
  ph="$ph   {{{{{{{{   \            \     /    __ _  ________     \    \n"
  ph="$ph   }}}}}}}}}   \'.__      _  |   /    /  ' \/ __/ __/___   |  \n"
  ph="$ph   {{{{{{{{       /\`._  (_\ /  <    / /_/_/\__/\______/   |  \n"
  ph="$ph    }}}}}}'      |    //___/    \  /_/ Michael Clayton    |   \n"
  ph="$ph    \`{{{{\`       |     '--'      \_______________________/  \n"
  ph="$ph     }}}'                                                     \n"
  ph="$ph                                                              \n"
  rainbowtext "$ph"
}

# Display the welcome splash screen
partyhorse
