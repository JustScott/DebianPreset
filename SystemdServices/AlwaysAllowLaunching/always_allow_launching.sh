#!/usr/bin/env bash
#
# always_allow_launching.sh - part of the DebianPreset project
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

if ! command -v gio &>/dev/null
then
    printf "\e[31m%s %s\e[0m" "[Error]" \
        "The command line tool 'gio' is not installed. Stopping." >&2
fi

trust_desktop_files()
{
    find "${HOME}/Desktop" -type f -name "*.desktop" -print0 \
        | while IFS= read -r -d '' file
    do
        gio set "$file" metadata::trusted true &>/dev/null
    done
}

run_constant_trust_loop()
{
    while true
    do
        sleep 300
        trust_desktop_files
    done
}

trust_on_creation_loop()
{
    inotifywait --monitor --event create "${HOME}/Desktop" | while read -r event
    do
        sleep 1
        trust_desktop_files
    done
}

run_constant_trust_loop &
trust_on_creation_loop
