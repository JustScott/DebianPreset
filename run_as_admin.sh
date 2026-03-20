#!/bin/bash
#
# run_as_admin.sh - part of the DebianPreset project
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
    grep \
)

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
            exit 1
        fi
    done
}

ensure_commands_installed

check_for_cache_server()
{
    if apt-config dump | grep "Proxy" &>/dev/null
    then
        cache_server_url=$(\
            apt-config dump \
            | grep "Proxy" \
            | awk -F'Proxy ' '{print $2}' \
            | awk -F';' '{print $1}')
        if [[ -n "$cache_server_url" ]]
        then
            curl --max-time 5 "$cache_server_url" \
                1>/dev/null 2>>$STDERR_LOG_PATH &
            task_output $! "$STDERR_LOG_PATH" \
                "Check connection to apt cache server at '$cache_server_url'"
            if [[ $? -ne 0 ]]
            then
                printf "\n\n\e[36m%s\e[0m\n\n" \
                    "[TIP] rm /etc/apt/apt.conf.d/10proxy to disable apt cache"
                exit 1
            fi
        fi
    fi

    return 0
}

check_for_cache_server

install_configure_flatpak()
{
    if ! dpkg -s flatpak &>/dev/null
    then
        sudo -v || return 1
        sudo apt-get install --yes flatpak \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Install flatpak"
        [[ $? -ne 0 ]] && return 1
    fi

    if flatpak remote-delete --system flathub &>/dev/null
    then
        printf "\e[32m[Success]\e[0m %s\n" \
            "Remove --system flathub remote from flatpak"
    fi

    if ! cmp -s ./Configurations/flathub_user.filter \
        /etc/flatpak/flathub_user.filter &>/dev/null
    then
        sudo -v || return 1

        if ! [[ -d /etc/flatpak ]]
        then
            sudo mkdir -p /etc/flatpak &>/dev/null
        fi

        sudo cp ./Configurations/flathub_user.filter \
            /etc/flatpak/flathub_user.filter \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Copy flathub --user filter to system"
        [[ $? -ne 0 ]] && return 1

        if ! sudo chmod o+r /etc/flatpak/flathub_user.filter &>/dev/null
        then
            printf "\n\e[31m%s %s %s\e[0m\n" \
                "[!] Failed to allow read access to" \
                "'/etc/flatpak/flathub_user.filter'. This shouldn't" \
                "happen...stopping"
            exit 1
        fi
    fi

    if ! dpkg -s gnome-software-plugin-flatpak &>/dev/null
    then
        sudo -v || return 1
        sudo apt-get install --yes gnome-software-plugin-flatpak \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Install flatpak plugin for gnome-software"
        [[ $? -ne 0 ]] && return 1
    fi

    # We don't want the user installing any system packages
    if dpkg -s gnome-software-plugin-deb &>/dev/null
    then
        sudo -v || return 1
        sudo apt-get remove --yes gnome-software-plugin-deb \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Remove deb plugin for gnome-software"
        [[ $? -ne 0 ]] && return 1
    fi

    if dpkg -s gnome-software-plugin-fwupd &>/dev/null
    then
        sudo -v || return 1
        sudo apt-get remove --yes gnome-software-plugin-fwupd \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Remove fwupd plugin for gnome-software"
        [[ $? -ne 0 ]] && return 1
    fi
}

install_configure_flatpak
