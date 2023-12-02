#!/usr/bin/env bash

wl-paste | sed 's/\\//' | tr -d '\r\n' | hurlfmt --in curl --out hurl
