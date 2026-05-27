# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Make EOL marker empty string instead of '%'
PROMPT_EOL_MARK=''

# Custom binding Overrides to use Ctrl+WASD to move around the terminal line
bindkey "^A" backward-word
bindkey "^D" forward-word # Note Ctrl+D is EOF, so this is a bit of a misnomer to override
bindkey "^S" beginning-of-line
bindkey "^W" end-of-line

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
    # Nix-prompt-inspired stacked badge prompt with a dark teal pill ramp and Catppuccin accents.
    setopt prompt_subst
    PROMPT_RESET=$'%{\e[0m%}'
    PROMPT_FG_BLUE=$'%{\e[38;2;138;173;244m%}'
    PROMPT_FG_GREEN=$'%{\e[38;2;166;218;149m%}'
    PROMPT_FG_YELLOW=$'%{\e[38;2;238;212;159m%}'
    PROMPT_FG_TEXT=$'%{\e[38;2;202;211;245m%}'
    PROMPT_PRIMARY_RGB='36;39;58'
    PROMPT_PATH_RGB='73;77;100'
    PROMPT_GIT_RGB='91;96;120'
    PROMPT_DARK_RGB='24;25;38'
    PROMPT_PRIMARY_FG_RGB='202;211;245'
    PROMPT_LIGHT_RGB='202;211;245'
    INITIALS='%BMCC%b'

    prompt_badge_zsh() {
      local label="$1"
      local bg_rgb="$2"
      local fg_rgb="${3:-$PROMPT_DARK_RGB}"

      if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
        printf '%s' "$label"
        return
      fi

      printf '%%{\033[38;2;%sm%%}' "$bg_rgb"
      printf '%%{\033[38;2;%s;48;2;%sm%%} %s ' "$fg_rgb" "$bg_rgb" "$label"
      printf '%%{\033[0m%%}'
      printf '%%{\033[38;2;%sm%%}' "$bg_rgb"
      printf '%%{\033[0m%%}'
    }

    prompt_leading_badge_zsh() {
      local label="$1"
      local bg_rgb="$2"
      local fg_rgb="${3:-$PROMPT_DARK_RGB}"
      local next_bg_rgb="${4:-}"

      if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
        printf '%s' "$label"
        return
      fi

      printf '%%{\033[38;2;%s;48;2;%sm%%} %s ' "$fg_rgb" "$bg_rgb" "$label"
      printf '%%{\033[0m%%}'
      if [ -n "$next_bg_rgb" ]; then
        printf '%%{\033[38;2;%s;48;2;%sm%%}' "$bg_rgb" "$next_bg_rgb"
      else
        printf '%%{\033[38;2;%sm%%}' "$bg_rgb"
      fi
      printf '%%{\033[0m%%}'
    }

    prompt_git_branch_name() {
      git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
    }

    prompt_git_badge_zsh() {
      local branch
      branch="$(prompt_git_branch_name)"
      [ -z "$branch" ] && return
      branch="${branch//\%/%%}"

      printf '%s' "$(prompt_leading_badge_zsh " $branch" "$PROMPT_GIT_RGB" "$PROMPT_LIGHT_RGB")"
    }

    prompt_plain_git_zsh() {
      local branch
      branch="$(prompt_git_branch_name)"
      [ -z "$branch" ] && return
      branch="${branch//\%/%%}"

      printf '%s' "$(prompt_ascii_segment_zsh "$branch" "$PROMPT_GIT_RGB" "$PROMPT_LIGHT_RGB")"
    }

    prompt_ascii_segment_zsh() {
      local label="$1"
      local bg_rgb="$2"
      local fg_rgb="${3:-$PROMPT_LIGHT_RGB}"
      local next_bg_rgb="${4:-}"

      printf '%%{\033[38;2;%s;48;2;%sm%%} %s ' "$fg_rgb" "$bg_rgb" "$label"
      if [ -n "$next_bg_rgb" ]; then
        printf '%%{\033[38;2;%s;48;2;%sm%%}>' "$bg_rgb" "$next_bg_rgb"
      else
        printf '%%{\033[0m%%}'
      fi
    }

    prompt_set_mcc_zsh() {
      if [ "$DISABLE_NERD_FONT_ICONS" = true ]; then
        PS1_LINE_1="$(prompt_ascii_segment_zsh "$INITIALS" "$PROMPT_PRIMARY_RGB" "$PROMPT_PRIMARY_FG_RGB" "$PROMPT_PATH_RGB")$(prompt_ascii_segment_zsh "%~" "$PROMPT_PATH_RGB" "$PROMPT_LIGHT_RGB" "$PROMPT_GIT_RGB")\$(prompt_plain_git_zsh)"
        PS1_LINE_2="${PROMPT_FG_YELLOW}    \$ $PROMPT_RESET"
      else
        PS1_LINE_1="$(prompt_leading_badge_zsh "$INITIALS" "$PROMPT_PRIMARY_RGB" "$PROMPT_PRIMARY_FG_RGB" "$PROMPT_PATH_RGB")$(prompt_leading_badge_zsh " %~" "$PROMPT_PATH_RGB" "$PROMPT_LIGHT_RGB" "$PROMPT_GIT_RGB")\$(prompt_git_badge_zsh)"
        PS1_LINE_2="$PROMPT_FG_YELLOW  󱞩  \$ $PROMPT_RESET"
      fi

      PS1="$PS1_LINE_1"$'\n'"$PS1_LINE_2"
      PROMPT="$PS1"
    }

    prompt_set_mcc_zsh
  fi
fi
