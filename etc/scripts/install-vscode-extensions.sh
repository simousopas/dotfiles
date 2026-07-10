#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically installs a user-defined list of VS Code extensions.
#
# Pre-conditions:
# - VSCode must be installed and the `code` CLI tool must be available in $PATH.
# - --extensions-list must point to a text file with a list of extensions.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --extensions-list: Point to the text file containing the list of extensions to install.

set -Eeuo pipefail

readonly VSC_DATA_DIR="$XDG_CACHE_HOME/code/data/"
readonly VSC_EXTENSIONS_DIR="$XDG_CACHE_HOME/code/extensions/"
readonly REMAINING_EXTENSIONS_LIST="$TMPDIR/vscode.extensions.txt"
readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
extensions_list=""
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
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		-v)
			verbose=1
			shift;;
		-vv)
			verbose=2
			shift;;
		--extensions-list)
			extensions_list="$2";
			shift;;
		*)
			shift;;
	esac; done
}

check_preconds () {
	log "Checking pre-conditions ..."

	if ! which -s code; then
		err "\`code\` was not found but it's required by this script."
		exit 1
	fi

	if [[ ! -f $extensions_list ]]; then
		err "--extensions-list must point to a file."
		exit 1
	fi
}


trap 'cleanup ERR' ERR
trap 'cleanup EXIT' EXIT
parse_input_args "$@"
check_preconds

if [ ! -f "$REMAINING_EXTENSIONS_LIST" ]; then
	log "Loading extensions list ..."
	stdo=1 run cat "$extensions_list" >"$REMAINING_EXTENSIONS_LIST"
fi

while IFS='' read -r ext
do
	ext_author=${ext%%*.}
	ext_name=${ext##*.}
	log "Installing $ext_name of $ext_author ..."
	run code \
		--user-data-dir "$VSC_DATA_DIR" \
		--extensions-dir "$VSC_EXTENSIONS_DIR" \
		--install-extension "$ext" \
		--force

	# Remove the last extension that was successfully installed so it won't be
	# reprocessed in case this script is re-executed after a failure.
	run sed -i '' '1d' "$REMAINING_EXTENSIONS_LIST"

done <<<"$(cat "$REMAINING_EXTENSIONS_LIST")"

rm -rf "$REMAINING_EXTENSIONS_LIST"
log "Done!"
