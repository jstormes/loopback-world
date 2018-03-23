#!/usr/bin/env bash
# Copy SSH key into local setup.
if [ ! -f ~/.ssh/id_rsa ]; then
    if [ -f /var/www/_ssh/id_rsa ]; then
        mkdir ~/.ssh
        # Force Unix line endings.
        sed -e 's/\r\n/\n/g' /var/www/_ssh/id_rsa > ~/.ssh/id_rsa
        chmod -R 400 ~/.ssh
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
        echo "###########################################################################"
        echo "# WARNING!!!!"
        echo "# SSH key was copied into docker image.  You should NOT push this image"
        echo "# to a Docker repo!"
        echo "###########################################################################"
    else
        echo "###########################################################################"
        echo "# SSH Key not found!!!"
        echo "# file not found: \\var\\www\\_ssh\\id_rsa"
        echo "# Copy a valid id_rsh key file into _ssh if you need to use secure git."
        echo "###########################################################################"
    fi
fi
