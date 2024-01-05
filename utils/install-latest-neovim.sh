#!/usr/bin/env bash

SECONDS=0
set -o pipefail

COMMIT_TAG="nightly"
# COMMIT_SHA="bdfea2a8919963dfe24052635883f0213cff83e8"
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

NVIM_VERSION=$(nvim --version | head -1 | sed 's/^NVIM \(v.*\)$/\1/')

log_info "Current neovim version: ${NVIM_VERSION}"

if [ -x "$(command -v nvim)" ]; then
	if [[ -z "$COMMIT_TAG" ]] && [[ -z "$COMMIT_SHA" ]] && [[ -x "$(command -v curl)" ]] && [[ -x "$(command -v jq)" ]]; then
		REMOTE_LATEST_COMMIT=$(curl -L -s -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$REMOTE_API_URL/commits?per_page=1" | jq -r '. | first .sha')
		REMOTE_LATEST_COMMIT_SHORT="$(git rev-parse --short=9 "$REMOTE_LATEST_COMMIT")"
		NVIM_LAST_BUILD_HEAD=$(echo "$NVIM_VERSION" | sed 's/.*+g\(.*\)$/\1/')

		log_info "Current neovim head: ${NVIM_LAST_BUILD_HEAD}"
		log_info "Checking neovim remote latest commit: ${REMOTE_LATEST_COMMIT} -> ${REMOTE_LATEST_COMMIT_SHORT}"

		if [[ "$NVIM_LAST_BUILD_HEAD" == "$REMOTE_LATEST_COMMIT_SHORT" ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild! Already at latest commit."
			exit 0
		fi
	elif [[ -n "$COMMIT_TAG" ]] && [[ -x "$(command -v curl)" ]] && [[ -x "$(command -v jq)" ]] && ! [[ "$COMMIT_TAG" =~ ^v\d\.\d\.\d ]]; then
		REMOTE_LATEST_COMMIT=$(curl -L -s -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$REMOTE_API_URL/git/matching-refs/tags/nightly" | jq -r '. | first | .object.sha')
		REMOTE_LATEST_COMMIT_SHORT="$(git rev-parse --short=9 "$REMOTE_LATEST_COMMIT")"
		NVIM_LAST_BUILD_HEAD=$(echo "$NVIM_VERSION" | sed 's/.*+g\(.*\)$/\1/')

		log_info "Current neovim head: ${NVIM_LAST_BUILD_HEAD}"
		log_info "Checking neovim remote latest commit: ${REMOTE_LATEST_COMMIT} -> ${REMOTE_LATEST_COMMIT_SHORT} for ${COMMIT_TAG}"

		if [ -n "$COMMIT_SHA" ]; then
			logger_warn "Commit sha is also set and ignored: ${COMMIT_SHA}"
		fi

		if [[ "$NVIM_LAST_BUILD_HEAD" == "$REMOTE_LATEST_COMMIT_SHORT" ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild! Already at latest commit for given rolling tag: ${COMMIT_TAG}"
			exit 0
		fi
	elif [ -n "$COMMIT_TAG" ]; then
		log_info "Checking neovim version against tag: ${COMMIT_TAG}"

		if [ -n "$COMMIT_SHA" ]; then
			logger_warn "Commit sha is also set and ignored: ${COMMIT_SHA}"
		fi

		if [[ "$NVIM_VERSION" == "$COMMIT_TAG" ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild!"
			exit 0
		fi
	elif [ -n "$COMMIT_SHA" ]; then
		NVIM_LAST_BUILD_HEAD=$(echo "$NVIM_VERSION" | sed 's/.*+g\(.*\)$/\1/')
		SHORT_COMMIT_SHA="$(git rev-parse --short=9 "$COMMIT_SHA")"

		log_info "Current neovim head: ${NVIM_LAST_BUILD_HEAD}"

		log_info "Checking neovim version against commit sha: ${COMMIT_SHA} -> ${SHORT_COMMIT_SHA}"

		if [[ "$NVIM_LAST_BUILD_HEAD" == "$SHORT_COMMIT_SHA" ]] && [[ -z "$NVIM_FORCE_BUILD" ]]; then
			log_warn "No need to rebuild!"
			exit 0
		fi
	fi
fi

ASSET=$(tr -cd 'a-f0-9' </dev/urandom | head -c 32)

TMP_DOWNLOAD_PATH="/tmp/${ASSET}"

log_debug "Temporary path: ${TMP_DOWNLOAD_PATH}"

log_start "Downloading neovim head~0..."
git clone https://github.com/neovim/neovim "$TMP_DOWNLOAD_PATH"
log_finish "Neovim cloned."

cd "$TMP_DOWNLOAD_PATH" || exit 127

if [ -n "$COMMIT_TAG" ]; then
	log_warn "Certain commit tag is set: ${COMMIT_TAG}"
	git checkout "$COMMIT_TAG"
elif [ -n "$COMMIT_SHA" ]; then
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
