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

PATH="/opt/cross/5.3.1_Conti/armv7-conti-linux-gnueabi/bin/:$PATH"
PATH="/opt/cross/7.4.1_Linaro/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/:$PATH"

wsl.exe -d wsl-vpnkit --cd /app service wsl-vpnkit start

### Aliases
# The best way to store your dotfiles: A bare Git repository
# https://www.ackama.com/what-we-think/the-best-way-to-store-your-dotfiles-a-bare-git-repository-explained/
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
