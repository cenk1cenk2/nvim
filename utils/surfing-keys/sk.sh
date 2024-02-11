#!/usr/bin/env bash

SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"
exec nvim --headless -c "luafile $SCRIPT_PATH/sk.lua"
