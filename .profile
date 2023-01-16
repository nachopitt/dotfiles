# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

### Exports
# COLORTERM is not available in Windows Terminal WSL2 Ubuntu 20.04
export COLORTERM=truecolor

# load dircolors
eval `dircolors ~/.dircolors`

PATH="/opt/cross/5.3.1_Conti/armv7-conti-linux-gnueabi/bin/:$PATH"
PATH="/opt/cross/7.4.1_Linaro/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/:$PATH"

wsl.exe -d wsl-vpnkit --cd /app service wsl-vpnkit start

### Aliases
# The best way to store your dotfiles: A bare Git repository
# https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

### Conti
PATH="$PATH:$HOME/scripts:$HOME/scripts/sync"
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
