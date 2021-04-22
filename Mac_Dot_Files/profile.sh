# this file is processed only when sh is running as a login (top-level) shell
# and should contain commands to be run once per session, e.g. setting
# environment variables and terminal-specific settings

# set PATH and MANPATH based on machine type
#eval `/usr/local/bin/defaultpaths`

# set default file/directory creation protection
umask 027

if [ "${BASH}" ]; then		# we're bash
  [ -f $HOME/.bashrc ] && . $HOME/.bashrc
elif [ `basename "${SHELL}"` = ksh ]; then	# we're ksh
  ENV=$HOME/.kshrc; export ENV
  [ -f $ENV ] && . $ENV
else # assume good ol' sh
  PS1="`shorthostname` $ "
fi

ENTOMB=yes; export ENTOMB
EDITOR=vim; export EDITOR #our default text editor
PAGER=less; export PAGER



export CLICOLOR=1

export LSCOLORS=GxFxCxDxBxegedabagaced
