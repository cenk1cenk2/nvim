#!/usr/bin/env zsh

wl-paste | sed 's/\\//' | tr -d '\r\n' | hurlfmt --in curl --out hurl
