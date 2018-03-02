#!/usr/bin/env bash
#
# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# Copy SSH key into local setup.
if [ ! -f ~/ssh/id_rsa ]; then
    sleep 20
    echo "################################"
    echo "# SSH Key not found!!!"
    echo "# file not found: \\var\\www\\_ssh\\id_rsa"
    echo "# Copy a valid id_rsh key file into _ssh if you need to use secure git."
    echo "################################"
    exit
else
    if [ ! -f ~/.ssh/id_rsa ]; then
        mkdir ~/.ssh
        # Force Unix line endings.
        sed -e 's/\r\n/\n/g' ~/ssh/id_rsa > ~/.ssh/id_rsa
        chmod -R 400 ~/.ssh
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
    fi
fi

export PATH ="/var/www/_docker/bin:$PATH"


echo
echo
echo " **********************************************************************"
echo " * This Docker container is for an interactive BASH shell.  It has     "
echo " * the following tools pre-loaded:                                     "
echo " *                                                                     "
echo " * composer"
echo " * phpunit"
echo " * phpunit/dbunit"
echo " * phing "
echo " * phpcpd "
echo " * phploc "
echo " * phpmd "
echo " * phpcs "
echo " * mysql "
echo " * curl "
echo " * net-tool "
echo " *                                                                     "
echo " **********************************************************************"
echo
echo

#exec bash

