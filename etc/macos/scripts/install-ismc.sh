#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

# README
# This script installs/updates iSMC, a CLI tool that decode temperatura, fans,
# battery, power, voltage and current of Apple Silicon macs.
#
# Pre-conditions
# - `curl` must be installed to install iSMC.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --bin-dir: Directory where the iSMC CLI program is going to be installed.
#	Defaults to "$HOME/.local/bin".
#	This location should be part of your $PATH if you intend to have `iSMC` available globally.
# --version: Select a specific version of iSMC to be installed.
# 	If no version is explicitly set or it's set to "latest", this script will
# 	query and use the latest one. All available version can be found here:
# 	https://github.com/dkorunic/iSMC/releases

set -Eeuo pipefail

readonly ISMC_DOWNLOAD_DIR="$TMPDIR/iSMC"
readonly ISMC_REPO="dkorunic/iSMC"
readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
ismc_bin_dir="$HOME/.local/bin"
version=""
verbose=0

log () { printf '[%s] %s\n' "${0##*/}" "$*" >&2; }
err () { printf '[%s] ERROR: %s\n' "${0##*/}" "$*" >&2; }

# Wrapper to run commands while controlling log verbosity and output redirection.
run () {
	[[ $verbose -gt 0 ]] && printf "\t%s\n" "$*" >&2

	local status=0
	if [[ $verbose == 2 ]]; then
		if [[ -v stdo && $stdo == 1 ]]; then
			"$@" 2>"$TMP_LOG_FILE"
		else
			"$@" &>"$TMP_LOG_FILE"
		fi
		status=$?
		sed 's/^/\t\t/' "$TMP_LOG_FILE"
	else
		if [[ -v stdo && $stdo == 1 ]]; then
			"$@" 2>/dev/null
		else
			"$@" &>/dev/null
		fi
		status=$?
	fi

	return $status
}

cleanup () {
	local err_code=$?
	local trap_signal="$1"
	[[ $trap_signal == "ERR" ]] && err "Command failed with exit code $err_code."

	rm -rf "$TMP_LOG_FILE"
	rm -rf "$TMPDIR/iSMC"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v)
			verbose=1
			shift;;
		-vv)
			verbose=2
			shift;;
		--bin-dir)
			ismc_bin_dir="$2"
			shift; shift;;
		--version)
			version="$2";
			shift; shift;;
		*)
			shift;;
	esac; done
}

check_preconds () {
	log "Checking pre-conditions ..."

	if ! which -s curl; then
		err "\`curl\` is required to download iSMC."
		exit 1
	fi

	if [[ ! -d $ismc_bin_dir ]]; then
		err "\$ismc_bin_dir is referencing a location that's not a directory: '$ismc_bin_dir'."
		exit 1
	fi
}

install_ismc () {
	if [[ -z $version || $version == "latest" ]]; then
		log "Querying iSMC's latest available version ..."
		version=$(
			stdo=1 run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${ISMC_REPO}/releases/latest" |
			stdo=1 run jq --raw-output '.name'
		)
		log "The latest available version is $version"
	fi

	log "Downloading iSMC to $TMPDIR/iSMC/iSMC.tar.gz ..."
	run mkdir -p "$ISMC_DOWNLOAD_DIR"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "$ISMC_DOWNLOAD_DIR/iSMC.tar.gz" \
		"https://github.com/${ISMC_REPO}/releases/download/${version}/iSMC_Darwin_all.tar.gz"

	log "Extracting iSMC ..."
	run tar --directory "$ISMC_DOWNLOAD_DIR" -xvf "$ISMC_DOWNLOAD_DIR/iSMC.tar.gz"

	log "Installing iSMC at $ismc_bin_dir/iSMC ..."
	run rm -rf "$ismc_bin_dir/iSMC"
	run mv "$ISMC_DOWNLOAD_DIR/iSMC" "$ismc_bin_dir/"
}

trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"
check_preconds "$@"
install_ismc
log "Done!"
