#!/usr/bin/env zsh

set -o pipefail

cbp | sed 's/\\//' | tr -d '\r\n' | hurlfmt --in curl --out hurl
