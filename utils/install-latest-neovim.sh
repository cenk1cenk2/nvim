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
source <(curl -s "https://gist.githubusercontent.com/cenk1cenk2/e03d8610534a9c78f755c1c1ed93a293/raw/logger.sh")

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
