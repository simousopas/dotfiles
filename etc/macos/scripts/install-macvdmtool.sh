#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

# README
# This scripts builds and installs AsahiLinux/macvdmtool.
#
# Pre-conditions:
# `git`, `make` and `cc` need to be available to clone and build macvdmtool's repo.
#
# The following switch are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --bin-dir: Directory where the macvdmtoll CLI program is going to be installed.
#	Defaults to "$HOME/.local/bin".
#	This location should be part of your $PATH if you intend to have `macvdmtool` available globally.
# --git-dir: Directory where the macvdmtool repo will be cloned to.
#	Defaults to "$CODE/github/".

set -Eeuo pipefail

readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
readonly MACVDM_REPO="AsahiLinux/macvdmtool"
macvdm_bin_dir="$HOME/.local/bin"
macvdm_git_dir="$CODE/github/"
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
		--bin-dir)
			macvdm_bin_dir="$2"
			shift; shift;;
		--git-dir)
			macvdm_git_dir="$2"
			shift; shift;;
		*)
			shift;;
	esac; done
}

check_preconds () {
	log "Checking pre-conditions ..."

	if ! which -s git; then
		err "\`git\` was not found but it's to clone macvdm's repo."
		exit 1
	fi

	if ! which -s cc; then
		err "\`cc\` was not found but it's to compile macvdm's source code."
		exit 1
	fi

	if ! which -s make; then
		err "\`make\` was not found but it's to build macvdm's from source."
		exit 1
	fi

	if [[ ! -d $macvdm_bin_dir ]]; then
		err "\$macvdm_bin_dir is referencing a location that's not a directory: '$macvdm_bin_dir'."
		exit 1
	fi
}

install_macvdm () {
	log "Cloning macvdmtool repo from $macvdm_git_dir/macvdmtool ..."
	run git clone "https://github.com/$MACVDM_REPO" "$macvdm_git_dir/macvdmtool"

	log "Building and then installing macvdmtool in $macvdm_bin_dir/macvdmtool ..."
	run pushd "$macvdm_git_dir/macvdmtool"
	run make
	run mv macvdmtool "$macvdm_bin_dir/macvdmtool"
	run popd
}

update_macvdm () {
	log "Updating preexisting setup ..."
	run git -C "$macvdm_git_dir/macvdmtool" clean -fddx
	run git -C "$macvdm_git_dir/macvdmtool" pull --prune

	log "Building and then installing macvdmtool in $macvdm_bin_dir/macvdmtool ..."
	run pushd "$macvdm_git_dir/macvdmtool"
	run make
	run mv macvdmtool "$macvdm_bin_dir/macvdmtool"
	run popd
}

trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"
check_preconds
if [[ $(stdo=1 run git -C "$macvdm_git_dir/macvdmtool" rev-parse --is-inside-work-tree) == "true" ]]; then
	update_macvdm
else
	install_macvdm
fi
log "Done!"
