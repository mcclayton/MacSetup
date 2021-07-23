# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Make EOL marker empty string instead of '%'
PROMPT_EOL_MARK=''

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code'
fi


export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# Load .bashrc if it exists
test -f ~/.bashrc && source ~/.bashrc

if [[ $(echo $ZSH_VERSION) ]]; then
  # Source fzf for current shell
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  # Set the prompt
  if [ "$TERM" != "dumb" ]; then
    # Nice pretty color prompt with the current host and our current directory
    RED='%F{9}'; GRAY='%F{8}'; BLUE='%F{blue}'; GREEN='%F{green}'
    INITIALS='MCC'
    BOLT='⚡️'
    ARROW_SEPARATOR='      ↳'
    HEARTS="$RED  "
    HEARTS_ARROW_SEPARATOR='       ↳'

    if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
      PS1_LINE_1="$BOLT  $GRAY$INITIALS:$BLUE%~$RED\$(parse_git_branch)"
      PS1_LINE_2="$GRAY$ARROW_SEPARATOR$GREEN  $ %{$reset_color%}"
    else
      PS1_LINE_1="$HEARTS  $GRAY$INITIALS:$BLUE%~$RED\$(parse_git_branch)"
      PS1_LINE_2="$GRAY$HEARTS_ARROW_SEPARATOR$GREEN  $ %{$reset_color%}"
    fi

    PS1="%B$PS1_LINE_1"$'\n'"$PS1_LINE_2%"
  fi
fi
