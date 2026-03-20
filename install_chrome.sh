#!/bin/bash
#
# install_chrome.sh - part of the DebianPreset project
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


REQUIRED_COMMANDS=(\
    cmp unattended-upgrades \
)

CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

PRETTY_OUTPUT_LIBRARY=./pretty_output_library.sh

if ! source $PRETTY_OUTPUT_LIBRARY &>/dev/null
then
    printf "\n\n\e[31m%s %s\e[0m\n\n" \
        "[!] Couldn't source the pretty output library. Make sure you're" \
        "in the base directory of ./DebianPreset before running scripts."
    exit 1
fi

ensure_commands_installed()
{
    for cmd in ${REQUIRED_COMMANDS[@]}
    do
        if ! command -v $cmd &>/dev/null
        then
            printf "\n\n\e[31m%s %s\e[0m\n\n" \
                "[!] Missing required command: '$cmd'. This shouldn't" \
                "happen...stopping"
            return 1
        fi
    done
}

ensure_commands_installed

install_chrome()
{
    if ! dpkg -s google-chrome-stable &>/dev/null
    then
        sudo -v || return 1
        curl -s -L "$CHROME_URL" -o "google-chrome-stable_current_amd64.deb" \
            1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" "wget the google-chrome .deb file"
        [[ $? -ne 0 ]] && return 1

        sudo apt-get install -y "./google-chrome-stable_current_amd64.deb" \
            1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" "Install Google Chrome"
        [[ $? -ne 0 ]] && return 1
    fi
}

# https://support.google.com/chrome/a/answer/7517525?hl=en#zippy=%2Cset-installation-policies-automatically-install-force-install-allow-or-block
set_chrome_extensions_policy()
{
    SYSTEM_EXTENSIONS_DIR="/etc/opt/chrome/policies/managed"
    EXTENSION_POLICIES_FILE="./Configurations/Extensions/extensions.json"

    if ! [[ -d "$SYSTEM_EXTENSIONS_DIR" ]]
    then
        sudo -v || return 1
        sudo mkdir -p "$SYSTEM_EXTENSIONS_DIR" \
            1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" \
            "Create google chrome extensions policies directory"
        [[ $? -ne 0 ]] && return 1
    fi

    if ! cmp -s $EXTENSION_POLICIES_FILE \
        $SYSTEM_EXTENSIONS_DIR/extensions.json &>/dev/null
    then
        sudo cp $EXTENSION_POLICIES_FILE \
            $SYSTEM_EXTENSIONS_DIR/extensions.json \
            1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" \
            "cp chrome extension policies file to system"
        [[ $? -ne 0 ]] && return 1
    fi
}

add_chrome_to_unattended_upgrades()
{
    if ! [[ -d "/etc/apt/apt.conf.d" ]]
    then
        printf "\n\n\e[31m%s %s\e[0m\n\n" \
            "[!] missing the '/etc/apt/apt.conf.d' directory. This shouldn't" \
            "happen...stopping"
        return 1
    fi

    if ! cmp -s ./Configurations/google-chrome \
        /etc/apt/apt.conf.d/google-chrome &>/dev/null
    then
        sudo cp ./Configurations/google-chrome \
            /etc/apt/apt.conf.d/google-chrome 1>/dev/null 2>>$STDERR_LOG_PATH &
        task_output $! "$STDERR_LOG_PATH" \
            "cp google-chrome unattended upgrades file to /etc/apt/apt.conf.d/"
        [[ $? -ne 0 ]] && return 1
    fi
}

install_chrome
set_chrome_extensions_policy
add_chrome_to_unattended_upgrades
