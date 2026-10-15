#!/bin/sh
##########################################
# Git clone for XREA
#
# Deprecated: previously used to clone a private repository for rapid deploy.
#
# Copyright © 2023 Kamigayatsuri
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# 我は汝に興味なく、汝も我に興味なし。我と汝の心懐を交わすに能わず。沈黙こそが価値。忘れ去らん。
#
##########################################
GIT_SSH_KEY_SUFFIX="paperman.jp"
GIT_SSH_HOST="paperman.github.com"
GIT_SSH_HOSTNAME="github.com"
GIT_SSH_USER="git"

GIT_REPOSITORY="kamigayatsuri/paperman.jp"
GIT_CLONE_DIR="$HOME/$(basename "$GIT_REPOSITORY")"

# generate key for git
KEY_FILE="$HOME/.ssh/id_rsa_${SSH_KEY_SUFFIX}"
if [ ! -e "$KEY_FILE" ]; then
    ssh-keygen -f "$KEY_FILE"
fi

# create a ssh config file
SSH_CONFIG="$HOME/.ssh/config"
if [ ! -e "$SSH_CONFIG" ]; then
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
fi

# validate the SSH host env.
# allow only ascii, digit, underscore, and hyphen
# to prevent unexpected characters from affecting to grep.
case "$GIT_SSH_HOST" in
    ''|*[!a-zA-Z0-9_-]*)
        printf '%s\n' "ERROR: Invalid SSH host alias: $GIT_SSH_HOST" >&2
        exit 1
        ;;
esac

# create an SSH config entry only if the host alias is not already defined.
if ! grep -qE "^[[:space:]]*Host[[:space:]]+${GIT_SSH_HOST}([[:space:]]|$)" "$SSH_CONFIG"; then
    # Add a blank line if the config file is not empty
    if [ -s "$SSH_CONFIG" ]; then
        printf '\n' >> "$SSH_CONFIG"
    fi

    # appending the SSH connection settings for this host alias.
    cat >> "$SSH_CONFIG" <<EOF
Host ${GIT_SSH_HOST}
    HostName ${GIT_SSH_HOSTNAME}
    User ${GIT_SSH_USER}
    IdentityFile ${KEY_FILE}
    IdentitiesOnly yes
EOF
fi

# display the pub-key and wait for user adding it to git.
printf '%s\n' 'Please add this public key as a deployment key in your repository settings:'
cat "${KEY_FILE}.pub" || exit 1

printf '\n%s\n' 'deployment key in the repository settings.'
printf '%s' 'Press Enter to continue...'
IFS= read -r _ || exit 1

# clone the repository
if [ ! -d "$GIT_CLONE_DIR/.git" ]; then
    git clone "git@${GIT_SSH_HOST}:${GIT_REPOSITORY}.git" "$GIT_CLONE_DIR" || exit 1
fi