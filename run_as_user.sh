#!/bin/bash
#
# run_as_user.sh - part of the DebianPreset project
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
    gnome-extensions \
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
            printf "\n\n\e[31m%s\e[0m\n\n" \
                "[!] Missing required command: '$cmd'"
            exit 1
        fi
    done
}

ensure_commands_installed

setup_gnome_extensions()
{
    GNOME_EXTENSIONS_DIR="./Gnome/Extensions"

    DASH_TO_PANEL_FILE="dash-to-paneljderose9.github.com.v72.shell-extension.zip"
    DASH_TO_PANEL_PATH="$GNOME_EXTENSIONS_DIR/$DASH_TO_PANEL_FILE"
    DASH_TO_PANEL_UUID="dash-to-panel@jderose9.github.com"

    V_SHELL_FILE="vertical-workspacesG-dH.github.com.v108.shell-extension.zip"
    V_SHELL_PATH="$GNOME_EXTENSIONS_DIR/$V_SHELL_FILE"
    V_SHELL_UUID="vertical-workspaces@G-dH.github.com"

    TILING_SHELL_FILE="tilingshellferrarodomenico.com.v71.shell-extension.zip"
    TILING_SHELL_PATH="$GNOME_EXTENSIONS_DIR/$TILING_SHELL_FILE"
    TILING_SHELL_UUID="tilingshell@ferrarodomenico.com"

    BLUR_MY_SHELL_FILE="blur-my-shellaunetx.v70.shell-extension.zip"
    BLUR_MY_SHELL_PATH="$GNOME_EXTENSIONS_DIR/$BLUR_MY_SHELL_FILE"
    BLUR_MY_SHELL_UUID="blur-my-shell@aunetx"

    CAFFEINE_FILE="caffeinepatapon.info.v59.shell-extension.zip"
    CAFFEINE_PATH="$GNOME_EXTENSIONS_DIR/$CAFFEINE_FILE"
    CAFFEINE_UUID="caffeine@patapon.info"

    gnome_extension_UUIDs="$(gnome-extensions list)"

    install_enable_extension()
    {
        ext_path=$1
        ext_UUID=$2

        if [[ -z "$ext_path" || -z "$ext_UUID" ]]
        then
            printf "\n\n\e[31m%s %s %s\e[0m\n\n" \
                "[!] No extension path or uuid provided to the" \
                "'install_enable_extension' function. this shouldn't" \
                "happen...stopping"
            exit 1
        fi

        if ! [[ -f "$ext_path" ]] &>/dev/null
        then
            printf "\n\n\e[31m%s %s\e[0m\n\n" \
                "[!] Extension bundle '$ext_path' doesn't exist, this" \
                "shouldn't happen...stopping"
            exit 1
        fi

        if echo "$gnome_extension_UUIDs" \
            | grep "$ext_UUID" &>/dev/null
        then
            if ! gnome-extensions info $ext_UUID \
                | grep "Enabled: Yes" &>/dev/null
            then
                gnome-extensions enable $ext_UUID \
                    >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
                task_output $! "$STDERR_LOG_PATH" \
                    "Enable Gnome extension: '$ext_UUID'"
                [[ $? -ne 0 ]] && exit 1
            fi
        else
            gnome-extensions install $ext_path &>/dev/null
            install_cmd_return_code=$?
            if [[ $install_cmd_return_code -eq 0 ]]
            then
                printf "\n\e[32m[Success]\e[0m %s\n" \
                    "Install Gnome extension: '$ext_path'"
            elif [[ $install_cmd_return_code -ne 2 ]]
            then
                printf "\n\e[31m[Error]\e[0m %s\n" \
                    "Install Gnome extension: '$ext_path'"
                exit 1
            fi
        fi    
    }
    
    install_enable_extension $DASH_TO_PANEL_PATH $DASH_TO_PANEL_UUID
    install_enable_extension $V_SHELL_PATH $V_SHELL_UUID
    install_enable_extension $TILING_SHELL_PATH $TILING_SHELL_UUID
    install_enable_extension $BLUR_MY_SHELL_PATH $BLUR_MY_SHELL_UUID
    install_enable_extension $CAFFEINE_PATH $CAFFEINE_UUID
}

setup_gnome_extensions
