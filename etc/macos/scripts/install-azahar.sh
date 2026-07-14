#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script installs/uninstalls the Azahar emulator.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --install-dir: Directory where the Azahar.app program is going to be installed.
#	Defaults to "/Applications".
# --uninstall: Uninstall the Azahar.app plus its cached files.
# --version: Select a specific version of Azahar to be installed.
# 	If no version is explicitly set or it's set to "latest", this script will
# 	query and use the latest one. All available version can be found here:
# 	https://github.com/azahar-emu/azahar/releases

set -Eeuo pipefail

readonly AZAHAR_DOWNLOAD_DIR="$TMPDIR/azahar"
readonly AZAHAR_REPO="azahar-emu/azahar"
readonly CPU_ARCH="$(uname -m)"
readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
azahar_install_dir="/Applications"
uninstall=0
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

	run rm -rf "$AZAHAR_DOWNLOAD_DIR"
	rm -rf "$TMP_LOG_FILE"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v)
			verbose=1
			shift;;
		-vv)
			verbose=2
			shift;;
		--install-dir)
			azahar_install_dir="$2"
			shift; shift;;
		--uninstall)
			uninstall=1
			shift;;
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
		err "\`curl\` is required to download Azahar."
		exit 1
	fi

	if [[ ! -d $azahar_install_dir ]]; then
		err "\$azahar_install_dir is referencing a location that's not a directory: '$azahar_install_dir'."
		exit 1
	fi
}

uninstall_azahar () {
	log "Uninstalling Azahar ..."
	run rm -rf "/$azahar_install_dir/Azahar.app"
	run rm -rf "$HOME/Library/Application Support/Azahar"
}

install_azahar () {
	if [[ -z $version || $version == "latest" ]]; then
		log "Querying Azahar's latest version ..."
		version=$(
			stdo=1 run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${AZAHAR_REPO}/releases/latest" |
			stdo=1 run jq --raw-output '.name'
		)
		version=${version#* }
		log "The latest available version is $version"
	fi

	log "Downloading Azahar to $AZAHAR_DOWNLOAD_DIR/azahar.zip ..."
	run mkdir -p "$AZAHAR_DOWNLOAD_DIR"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "$AZAHAR_DOWNLOAD_DIR/azahar.zip" \
		"https://github.com/${AZAHAR_REPO}/releases/download/${version}/azahar-macos-${CPU_ARCH}-${version}.zip"

	log "Extracting Azahar ..."
	run unzip "$AZAHAR_DOWNLOAD_DIR/azahar.zip" -d "$AZAHAR_DOWNLOAD_DIR"

	log "Installing Azahar at $azahar_install_dir/Azahar.app ..."
	run rm -rf "$azahar_install_dir/Azahar.app"
	run mv "$AZAHAR_DOWNLOAD_DIR/azahar-macos-${CPU_ARCH}-${version}/Azahar.app" "$azahar_install_dir/"
}

trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"
check_preconds
if [[ $uninstall == 1 ]]; then
	uninstall_azahar
else
	install_azahar
fi
log "Done!"
