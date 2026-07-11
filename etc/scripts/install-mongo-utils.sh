#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically install MongoDB Shell and MongoDB Tools.
#
# Pre-conditions:
# - `curl` and `jq` must installed if the MongoDB Shell/Tools version to be
#   installed is set to "latest".
# - `curl` and `unzip` must installed to download and extract MongoDB
#   Shell/Tools packages.
# - MongoDB Shell/Tools installation location must be a valid directory.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --shell-bin-dir: Directory where to install MongoDB Shell utils.
# 	Defaults to "$HOME/.local/bin".
# --shell-version: MongoDB Shell version to install. If set to "latest"
#   it will find and download the latest available version.
# 	The list of releases can be found here: https://github.com/mongodb-js/mongosh/releases
# --tools-bin-dir: Directory where to install MongoDB Tools utils.
# 	Defaults to "$HOME/.local/bin".
# --tools-version: MongoDB Tools version to install. If set to "latest"
#   it will download the latest available version.
# 	The list of releases can be found here: https://github.com/mongodb/mongo-tools/tags
set -Eeuo pipefail

readonly CPU_ARCH="$(uname -m)"
readonly MONGODB_SHELL_REPO="mongodb-js/mongosh"
readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
mongodb_shell_bin_dir="$HOME/.local/bin"
mongodb_shell_version=""
mongodb_tools_bin_dir="$HOME/.local/bin"
mongodb_tools_version=""
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
	rm -rf "${TMPDIR}mongodb"*
	rm -rf "${TMPDIR}mongosh"*
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--shell-bin-dir)
			mongodb_shell_bin_dir="$2";
			shift; shift;;
		--shell-version)
			mongodb_shell_version="$2";
			shift; shift;;
		--tools-bin-dir)
			mongodb_tools_bin_dir="$2";
			shift; shift;;
		--tools-version)
			mongodb_tools_version="$2";
			shift; shift;;
		-v)
			verbose=1
			shift;;
		-vv)
			verbose=2
			shift;;
		*)
			shift;;
	esac; done
}

check_preconds () {
	if [[ $mongodb_shell_version == "latest" ]] && ! which -s curl; then
		err "When --shell-version is set to 'latest' \`curl\` is required to fetch the latest release."
		exit 1
	fi

	if [[ $mongodb_shell_version == "latest" ]] && ! which -s jq; then
		err "When --shell-version is set to 'latest' \`jq\` is required to fetch the latest release."
		exit 1
	fi

	if [[ -n $mongodb_shell_version ]] && ! which -s curl; then
		err "When --shell-version is set, \`curl\` is required to download its package."
		exit 1
	fi

	if [[ -n $mongodb_shell_version ]] && ! which -s unzip; then
		err "When --shell-version is set, \`unzip\` is required to extract its package."
		exit 1
	fi

	if [[ -n $mongodb_tools_version ]] && ! which -s curl; then
		err "When --tools-version is set, \`curl\` is required to download its package."
		exit 1
	fi

	if [[ -n $mongodb_tools_version ]] && ! which -s unzip; then
		err "When --tools-version is set, \`unzip\` is required to extract its package."
		exit 1
	fi

	if [[
		-n $mongodb_shell_version &&
		-n $mongodb_shell_bin_dir &&
		! -d $mongodb_shell_bin_dir ]]; then
		err "--shell-bin-dir is set but doesn't point to a valid directory: $mongodb_shell_bin_dir"
		exit 1
	fi

	if [[
		-n $mongodb_shell_version &&
		-n $mongodb_tools_bin_dir &&
		! -d $mongodb_tools_bin_dir ]]; then
		err "--tools-bin-dir is set but doesn't point to a valid directory: $mongodb_tools_bin_dir"
		exit 1
	fi
}

install_mongodb_shell () {
	if [[ $mongodb_shell_version == "latest" ]]; then
		log "Querying MongoDB Shell latest available version ..."
		mongodb_shell_version=$(
			stdo=1 run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/${MONGODB_SHELL_REPO}/releases/latest" |
			jq --raw-output '.name'
		)
		log "MongoDB Shell latest version is ${mongodb_shell_version}"
	fi

	log "Downloading MongoDB Shell ..."
	local _cpu_arch="$CPU_ARCH"
	[[ "$_cpu_arch" == "x86_64" ]] && _cpu_arch="x64"
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--header "Accept:application/vnd.github.v3.raw" \
		--output "${TMPDIR}mongosh.zip" \
		"https://github.com/${MONGODB_SHELL_REPO}/releases/download/v${mongodb_shell_version}/mongosh-${mongodb_shell_version}-darwin-${_cpu_arch}.zip"

	log "Extracting ${TMPDIR}mongosh.zip ..."
	run unzip "${TMPDIR}mongosh.zip" -d "$TMPDIR"

	log "Installing MongoDB Shell in $mongodb_shell_bin_dir/ ..."
	run rm -rf "$mongodb_shell_bin_dir/mongosh"
	run mv "${TMPDIR}mongosh-${mongodb_shell_version}-darwin-${_cpu_arch}/bin/mongosh" "$mongodb_shell_bin_dir/"
}

install_mongodb_tools () {
	[[ "$mongodb_tools_version" == "latest" ]] && mongodb_tools_version="100.17.0"

	log "Downloading MongoDB Tools version ${mongodb_tools_version} ..."
	run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--output "${TMPDIR}mongodb-tools.zip" \
		"https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-${CPU_ARCH}-${mongodb_tools_version}.zip"

	log "Extracting ${TMPDIR}mongodb-tools.zip ..."
	run unzip "${TMPDIR}mongodb-tools.zip" -d "$TMPDIR"

	log "Installing MongoDB Tools in $mongodb_tools_bin_dir/ ..."
	run rm -rf "$HOME/.local/bin"/mongo{dump,export,files,import,restore,stat,top}
	run mv "${TMPDIR}mongodb-database-tools-macos-${CPU_ARCH}-${mongodb_tools_version}/bin/mongo"* "$mongodb_tools_bin_dir/"
}


trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"
check_preconds
[[ -n $mongodb_shell_version ]] && install_mongodb_shell
[[ -n $mongodb_tools_version ]] && install_mongodb_tools
