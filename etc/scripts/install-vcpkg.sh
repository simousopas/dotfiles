#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

# README
# This script helps installing/updating Microsoft's C++ package manager (vcpkg).
#
# Pre-conditions:
# - $VCPKG_ROOT must point to the location where the vcpkg git repo will be placed.
# - `git` must be installed in order to handle vcpkg's git repo.
# - `curl` and `jq` must be available if --version is not explicitly set.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --bin_dir: Directory where the vcpkg CLI program is going to be installed.
#	Defaults to "$HOME/.local/bin".
#	This location should be part of your $PATH if you intend to have `vcpkg` available globally.
# --version: Select a specific version of vcpkg to be installed.
# 	If no version is explicitly set, this script will query and use the latest one.
#	All available version can be found here: https://github.com/microsoft/vcpkg/tags

set -Eeuo pipefail

readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
readonly VCPKG_REPO="microsoft/vcpkg"
vcpkg_bin_dir="$HOME/.local/bin"
vcpkg_version=""
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
	rm -rf "$TMPDIR/vcpkg"
	while [ "$(dirs -p | wc -l)" -gt 1 ]; do
		popd >/dev/null
	done
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v)
			verbose=1
			shift;;
		-vv)
			verbose=2
			shift;;
		--bin_dir)
			vcpkg_bin_dir="$2"
			shift; shift;;
		--version)
			vcpkg_version="$2";
			shift; shift;;
		*)
			shift;;
	esac; done
}

check_preconds () {
	log "Checking pre-conditions ..."

	[[ -z $VCPKG_ROOT ]] &&
		err "This script requires \$VCPKG_ROOT to be set upfront." &&
		exit 1

	if ! which -s git; then
		err "\`git\` was not found but it's required by this script."
		exit 1
	fi

	if [[ -z $vcpkg_version ]] && ! which -s curl; then
		err "When --version is not specified \`curl\` is required to fetch vcpkg release metadata."
		exit 1
	fi

	if [[ -z $vcpkg_version ]] && ! which -s jq; then
		err "When --version is not specified \`jq\` is required to parse vcpkg release metadata."
		exit 1
	fi

	if [[ ! -d $vcpkg_bin_dir ]]; then
		err "\$vcpkg_bin_dir is referencing a location that's not a directory: '$vcpkg_bin_dir'."
		exit 1
	fi
}

install_vcpkg () {
	log "Cloning version @$vcpkg_version..."
	run git clone --branch "$vcpkg_version" "https://github.com/$VCPKG_REPO" "$TMPDIR/vcpkg"

	log "Bootstrapping vcpkg ..."
	run pushd "$TMPDIR/vcpkg"
	run ./bootstrap-vcpkg.sh
	run popd

	log "Installing vcpkg ..."
	[[ -d $VCPKG_ROOT ]] && run rm -rf "$VCPKG_ROOT"
	run mv "$TMPDIR/vcpkg" "$VCPKG_ROOT"
	run ln -fs "$VCPKG_ROOT/vcpkg" "$vcpkg_bin_dir/vcpkg"

	log "Done!"
}

update_vcpkg () {
	log "Updating preexisting setup ..."
	run pushd "$VCPKG_ROOT"
	run git checkout master
	run git pull --prune
	run git checkout "$vcpkg_version"

	log "Bootstrapping and installing vcpkg ..."
	run ./bootstrap-vcpkg.sh
	run ln -fs "$VCPKG_ROOT/vcpkg" "$vcpkg_bin_dir/vcpkg"

	run popd
	log "Done!"
}


trap 'cleanup ERR' ERR
trap 'cleanup EXIT' EXIT
parse_input_args "$@"
check_preconds

if [[ -z "$vcpkg_version" ]]; then
	log "Querying vcpkg latest available version ..."
	vcpkg_version=$(
		stdo=1 run curl --fail --location --show-error --silent \
			--connect-timeout 13 --retry 5 --retry-delay 2 \
			--header "Accept:application/vnd.github.v3.raw" \
			"https://api.github.com/repos/$VCPKG_REPO/releases/latest" |
		stdo=1 run jq --raw-output '.tag_name'
	)
	log "The latest available version is $vcpkg_version"
fi

if [[ -d $VCPKG_ROOT && $(git rev-parse --is-inside-work-tree) == "true" ]]; then
	update_vcpkg
else
	install_vcpkg
fi
