#!/bin/bash
#
# install_ufw.sh - part of the DebianPreset project
# Copyright (C) 2026, Scott Wyman, development@scottwyman.me
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


PRETTY_OUTPUT_LIBRARY=./pretty_output_library.sh

if ! source $PRETTY_OUTPUT_LIBRARY &>/dev/null
then
    printf "\n\n\e[31m%s %s\e[0m\n\n" \
        "[!] Couldn't source the pretty output library. Make sure you're" \
        "in the base directory of ./DebianPreset before running scripts."
    exit 1
fi

install_ufw()
{
    if ! dpkg -s ufw &>/dev/null
    then
        sudo apt-get install -y ufw \
            1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" "Install ufw"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}

block_incoming_traffic()
{
    if ! sudo ufw status verbose | grep "deny (incoming)" &>/dev/null
    then
        sudo ufw default deny incoming 1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" "Deny incoming traffic by default"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}

enable_ufw()
{
    if sudo ufw status verbose | grep "Status: inactive" &>/dev/null
    then
        sudo ufw enable 1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" "Enable ufw"
        [[ $? -ne 0 ]] && return 1
    fi

    return 0
}


sudo -v || exit 1
install_ufw || exit 1
block_incoming_traffic || exit 1
enable_ufw
