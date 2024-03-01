#!/usr/bin/env bash

SECONDS=0
set -o pipefail

COMMIT_TAG="nightly"
# https://github.com/zbirenbaum/copilot.lua/issues/273
# COMMIT_SHA="091e374c7f4886ef875e801ae0473b88f6caefe2"
# PATCHES=("https://patch-diff.githubusercontent.com/raw/neovim/neovim/pull/20130.patch")

REMOTE_API_URL="https://api.github.com/repos/neovim/neovim"

## inject logger
LOG_LEVEL=${LOG_LEVEL-"INFO"}
# shellcheck disable=SC1090
# . <(curl -s "https://gist.githubusercontent.com/cenk1cenk2/e03d8610534a9c78f755c1c1ed93a293/raw/logger.sh")

## logger.sh embedded, to manual update: https://gist.github.com/cenk1cenk2/e03d8610534a9c78f755c1c1ed93a293

# coloring
# formats
export RESET='\033[0m'
export BOLD='\033[1m'
export DIM='\033[2m'
export UNDERLINE='\033[4m'

# Regular Colors
export BLACK='\033[38;5;0m'
export RED='\033[38;5;1m'
export GREEN='\033[38;5;2m'
export YELLOW='\033[38;5;3m'
export BLUE='\033[38;5;4m'
export MAGENTA='\033[38;5;5m'
export CYAN='\033[38;5;6m'
export WHITE='\033[38;5;7m'

# Background
export ON_BLACK='\033[48;5;0m'
export ON_RED='\033[48;5;1m'
export ON_GREEN='\033[48;5;2m'
export ON_YELLOW='\033[48;5;3m'
export ON_BLUE='\033[48;5;4m'
export ON_MAGENTA='\033[48;5;5m'
export ON_CYAN='\033[48;5;6m'
export ON_WHITE='\033[48;5;7m'

# predefined
SEPARATOR="${DIM}-------------------------${RESET}"

# default log level and log levels
LOG_LEVEL=${LOG_LEVEL:-"INFO"}

declare -A LOG_LEVELS=([0]=0 [SILENT]=0 [silent]=0 [1]=1 [ERROR]=1 [error]=1 [2]=2 [WARN]=2 [warn]=2 [3]=3 [LIFETIME]=3 [lifetime]=3 [4]=4 [INFO]=4 [info]=4 [5]=5 [DEBUG]=5 [debug]=5)

# log function
log() {
	local LEVEL="${2}"

	if [[ ${LOG_LEVELS[$LEVEL]} ]] && [[ ${LOG_LEVELS[$LOG_LEVEL]} -ge ${LOG_LEVELS[$LEVEL]} ]]; then
		echo -e "${1}"
	fi
}

# general logging function with seperators and level parsing
log_this() {
	INFO="${1:-}"
	SCOPE="${2:-}"
	LEVEL="${3:-"INFO"}"
	SEPARATOR_INSERT="${4:-}"

	DATA="${INFO}"

	if [ -n "${SCOPE}" ] && [ "${SCOPE}" != "false" ]; then
		DATA="[${SCOPE}] ${DATA}"
	fi

	if [ -n "${SEPARATOR_INSERT}" ]; then
		if [[ ${SEPARATOR_INSERT} == "top" ]] || [[ ${SEPARATOR_INSERT} == "both" ]]; then
			DATA="${SEPARATOR}\n${DATA}"
		fi

		if [[ ${SEPARATOR_INSERT} == "bottom" ]] || [[ ${SEPARATOR_INSERT} == "both" ]]; then
			DATA="${DATA}\n${SEPARATOR}"
		fi
	fi

	log "${DATA}" "${LEVEL}"
}

# LOG_LEVEL = 1
log_error() {
	log_this "${1:-}" "${RED}ERROR${RESET}" "ERROR" "${2:-}"
}

log_interrupt() {
	log_this "${1:-}" "${RED}INTERRUPT${RESET}" "ERROR" "${2:-}"
}

# LOG_LEVEL = 2
log_warn() {
	log_this "${1:-}" "${YELLOW}WARN${RESET}" "WARN" "${2:-}"
}

# LOG_LEVEL = 3
log_start() {
	log_this "${1:-}" "${GREEN}START${RESET}" "LIFETIME" "${2:-}"
}

log_finish() {
	log_this "${1:-}" "${GREEN}FINISH${RESET}" "LIFETIME" "${2:-}"
}

# LOG_LEVEL = 4
log_info() {
	log_this "${1:-}" "${CYAN}INFO${RESET}" "INFO" "${2:-}"
}

log_wait() {
	log_this "${1:-}" "${YELLOW}WAIT${RESET}" "INFO" "${2:-}"
}

log_divider() {
	log "${SEPARATOR}" "INFO"
}

# LOG_LEVEL = 5
log_debug() {
	log_this "${1:-}" "${DIM}DEBUG${RESET}" "DEBUG" "${2:-}"
}

## END logger.sh embedded

log_this "" "${BLUE}build-neovim${RESET}" "LIFETIME" "bottom"
log_this "${COMMIT_TAG}" "${MAGENTA}COMMIT_TAG${RESET}" "LIFETIME"
log_this "${COMMIT_SHA}" "${MAGENTA}COMMIT_SHA${RESET}" "LIFETIME"
log_this "${PATCHES}" "${MAGENTA}PATCHES${RESET}" "LIFETIME"
log_this "${NVIM_FORCE_BUILD}" "${MAGENTA}NVIM_FORCE_BUILD${RESET}" "LIFETIME"
log_divider

NVIM_VERSION=$(nvim --version | head -1 | sed -E 's/^NVIM (v.*)$/\1/')
NVIM_LAST_BUILD_HEAD=$(echo "$NVIM_VERSION" | sed -E 's/.*(-dev-|\+g)(.*)$/\2/')

log_info "Current neovim version: ${NVIM_VERSION}"

if [ -x "$(command -v nvim)" ]; then
	if [[ -z "$COMMIT_TAG" ]] && [[ -z "$COMMIT_SHA" ]] && [[ -x "$(command -v curl)" ]] && [[ -x "$(command -v jq)" ]]; then
		REMOTE_LATEST_COMMIT=$(curl -L -s -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$REMOTE_API_URL/commits?per_page=1" | jq -r '. | first .sha')

		log_info "Current neovim head: ${NVIM_LAST_BUILD_HEAD}"
		log_info "Checking neovim remote latest commit: ${REMOTE_LATEST_COMMIT}"

		if [[ "$REMOTE_LATEST_COMMIT" =~ "$NVIM_LAST_BUILD_HEAD".* ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild! Already at latest commit."
			exit 0
		fi
	elif [[ -n "$COMMIT_TAG" ]] && [[ -x "$(command -v curl)" ]] && [[ -x "$(command -v jq)" ]] && ! [[ "$COMMIT_TAG" =~ ^v\d\.\d\.\d ]]; then
		REMOTE_LATEST_COMMIT=$(curl -L -s -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$REMOTE_API_URL/git/matching-refs/tags/nightly" | jq -r '. | first | .object.sha')

		log_info "Current neovim head: ${NVIM_LAST_BUILD_HEAD}"
		log_info "Checking neovim remote latest commit: ${REMOTE_LATEST_COMMIT} for ${COMMIT_TAG}"

		if [[ "$REMOTE_LATEST_COMMIT" =~ "$NVIM_LAST_BUILD_HEAD".* ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild! Already at latest commit for given rolling tag: ${COMMIT_TAG}"
			exit 0
		fi
	elif [ -n "$COMMIT_TAG" ]; then
		log_info "Checking neovim version against tag: ${COMMIT_TAG}"

		if [[ "$NVIM_VERSION" == "$COMMIT_TAG" ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild!"
			exit 0
		fi
	elif [ -n "$COMMIT_SHA" ]; then
		log_info "Current neovim head: ${NVIM_LAST_BUILD_HEAD}"
		log_info "Checking neovim version against commit sha: ${COMMIT_SHA}"

		if [[ "$COMMIT_SHA" =~ "$NVIM_LAST_BUILD_HEAD".* ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild!"
			exit 0
		fi
	fi
fi

TMP_DOWNLOAD_PATH=$(mktemp -d -t neovim-XXXXXXXXXX)

log_debug "Temporary path: ${TMP_DOWNLOAD_PATH}"

log_start "Downloading neovim head~0..."
if [ -n "$COMMIT_TAG" ]; then
	git clone https://github.com/neovim/neovim "$TMP_DOWNLOAD_PATH" --branch "${COMMIT_TAG}" --single-branch --depth 1
	log_warn "Certain commit tag is set: ${COMMIT_TAG}"
else
	git clone https://github.com/neovim/neovim "$TMP_DOWNLOAD_PATH" --single-branch
fi
log_finish "Neovim cloned."

cd "$TMP_DOWNLOAD_PATH" || exit 127

if [ -n "$COMMIT_SHA" ]; then
	log_warn "Certain commit sha is set: ${COMMIT_SHA}"
	git checkout "$COMMIT_SHA"
fi

for PATCH in "${PATCHES[@]}"; do
	log_info "Applying patch: $PATCH"

	rm p.patch
	wget -O "p.patch" "$PATCH"
	git apply p.patch
done

log_start "Building neovim..."
sudo make CMAKE_BUILD_TYPE=Release install
log_finish "Finished installing neovim."

log_debug "Clean up temporary path."
sudo rm -r "$TMP_DOWNLOAD_PATH"

if [ -f "/bin/nvim" ]; then
	log_warn "Neovim installed with fuse appimage deleting it first."
	sudo rm /bin/nvim
fi

## goodbye
log_finish "Built neovim in $((SECONDS / 60)) minutes and $((SECONDS % 60)) seconds." "top"
