#!/usr/bin/env bash

SECONDS=0
# COMMIT_TAG="nightly"
COMMIT_SHA="bdfea2a8919963dfe24052635883f0213cff83e8"
# PATCHES=("https://patch-diff.githubusercontent.com/raw/neovim/neovim/pull/20130.patch")

## inject logger
LOG_LEVEL=${LOG_LEVEL-"INFO"}
# shellcheck disable=SC1090
source <(curl -s "https://gist.githubusercontent.com/cenk1cenk2/e03d8610534a9c78f755c1c1ed93a293/raw/logger.sh")

if [ -x "$(command -v nvim)" ]; then
	if [ -n "$COMMIT_TAG" ]; then
		NVIM_VERSION=$(nvim --version | sed 's/^NVIM \(v.*\)$/\1/' | head -1)

		log_info "Current neovim version: ${NVIM_VERSION}"

		log_warn "Checking neovim version against tag: ${COMMIT_TAG}"

		if [[ $NVIM_VERSION == "$COMMIT_TAG" ]]; then
			log_warn "No need to rebuild!"
			exit 0
		fi
	elif [ -n "$COMMIT_SHA" ]; then
		NVIM_VERSION=$(nvim --version | sed 's/.*+g\(.........\)$/\1/' | head -1)

		log_info "Current neovim version: ${NVIM_VERSION}"

		SHORT_COMMIT_SHA=$(echo "$COMMIT_SHA" | cut -c1-9)

		log_warn "Checking neovim version against commit sha: ${COMMIT_SHA} -> ${SHORT_COMMIT_SHA}"

		if [[ $NVIM_VERSION == "$SHORT_COMMIT_SHA" ]]; then
			log_warn "No need to rebuild!"
			exit 0
		fi
	fi
fi

log_this "[install-nvim]" "false" "lifetime" "bottom"

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
