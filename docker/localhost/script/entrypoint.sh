#!/bin/sh
# entry script for docker container
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
echo "---- ENTRY SCRIPT START ----"

# for composer cache
# * -p option make parent directories
mkdir -p /var/www/.cache
chown "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" /var/www/.cache

# for npm cache
# * -p option make parent directories
mkdir -p /var/www/.npm
chown "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" /var/www/.npm

npm install -g npm@latest

cd /var/www/src || {
    printf '%s\n' "ERROR: Failed to change directory to /var/www/src" >&2
    exit 1
}

# 常時、最新化を行う
sudo -u "${APACHE_RUN_USER}" npm install
sudo -u "${APACHE_RUN_USER}" npm update
sudo -u "${APACHE_RUN_USER}" npm audit fix
sudo -u "${APACHE_RUN_USER}" npm run dev

chown "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" -R /var/www/src

echo "---- ENTRY SCRIPT END ----"

# Replace the shell with the main process.
# Do not remove this,
# or the container will exit with code 0 instead of staying running.
exec "$@"