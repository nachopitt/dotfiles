# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

function TQLA337W {
    echo "Environment is VM/WSL2: $1"

    PATH="/opt/cross/5.3.1_Conti/armv7-conti-linux-gnueabi/bin/:$PATH"
    PATH="/opt/cross/7.4.1_Linaro/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/:$PATH"

#    wsl.exe -d wsl-vpnkit --cd /app service wsl-vpnkit start
}

function fps211un {
    echo "Environment is BUILD-SERVER: $1"
    PATH="$PATH:$HOME/scripts:$HOME/scripts/sync"
}

function nachopitt-pc {
    echo "Environment is VM/WSL2: $1"
}

function unknown {
    echo "Environment is UNKNOWN: $1"
}

hostname=$(hostname)

case "$hostname" in
    "TQLA337W" | "TQLA337W-ubuntu")
        TQLA337W $hostname
        ;;
    "fps211un")
        fps211un $hostname
        ;;
    "nachopitt-pc" | "nachopitt-pc-ubuntu")
        nachopitt-pc $hostname
        ;;
    *)
        unknown $hostname
        ;;
esac

export PATH="$HOME/.local/bin:$PATH"

if [ -z ${SSH_CLIENT+x} ]; then
    echo "SSH_CLIENT is unset";
else
    SSH_CLIENT_IP=${SSH_CLIENT%% *}
fi

source "$HOME/.bash_functions"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# This is needed to list first the hidden files and then the non-hidden files
alias ls='LC_COLLATE=C.UTF-8 ls'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

### Exports

# https://askubuntu.com/questions/162391/how-do-i-fix-my-locale-issue
# export LC_ALL="C.UTF-8"

# So "tput colors" outputs 24 bit colors or 16777216
# export TERM=xterm-direct

# COLORTERM is not available in Windows Terminal WSL2 Ubuntu 20.04
# export COLORTERM=truecolor

case $TERM in
    iterm               |\
    linux-truecolor     |\
    screen-truecolor    |\
    tmux-truecolor      |\
    xterm-truecolor     |\
    xterm-direct        )   export COLORTERM=truecolor ;;
    vte*)
esac

if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# -----------------------------------------------------------
# Setup ssh-agent
# -----------------------------------------------------------

SSH_ENV="$HOME/.ssh/.agent_env"

function start_agent {
    echo "Initialising new SSH agent..."

    eval `/usr/bin/ssh-agent`
    echo 'export SSH_AUTH_SOCK'=$SSH_AUTH_SOCK >> ${SSH_ENV}
    echo 'export SSH_AGENT_PID'=$SSH_AGENT_PID >> ${SSH_ENV}

    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# create our own hardlink to the socket (with random name)
MYSOCK=/tmp/ssh_agent.${RANDOM}.sock
ln -T $SSH_AUTH_SOCK $MYSOCK
export SSH_AUTH_SOCK=$MYSOCK

end_agent()
{
    # if we are the last holder of a hardlink, then kill the agent
    nhard=`ls -l $SSH_AUTH_SOCK | awk '{print $2}'`
    if [[ "$nhard" -eq 2 ]]; then
        rm ${SSH_ENV}
        /usr/bin/ssh-agent -k
    fi
    rm $SSH_AUTH_SOCK
}
trap end_agent EXIT
set +x

# fnm
FNM_PATH="/home/uidr7643/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
