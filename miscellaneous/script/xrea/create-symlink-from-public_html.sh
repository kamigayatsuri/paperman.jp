#!/bin/sh
##########################################
# installer for XREA
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

##########################################
SOURCE_DIR="$HOME/paperman.jp/src/public"
PUBLIC_DIR="$HOME/public_html"
DOMAIN="paperman.jp"

NAME_SYMLINK="$PUBLIC_DIR/$DOMAIN"

# create symlink from public_html
if [ ! -L "$NAME_SYMLINK" ]; then
    if [ -d "$NAME_SYMLINK" ]; then
        // delete directory
        rmdir "$NAME_SYMLINK" || exit 1
    elif [ -e "$NAME_SYMLINK" ]; then
        echo "Error: $NAME_SYMLINK exists and is not a directory or symlink." >&2
        exit 1
    fi

    // create symlink
    ln -s "$SOURCE_DIR" "$NAME_SYMLINK" || exit 1
fi
