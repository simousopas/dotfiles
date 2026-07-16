#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically toggles read-only permissions for a set of apps
# to prevent them being updated automatically by their own update systems.
# Consecutive runs of this script will toggle those permissions back and forth.
#
# The following switches are available:
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.
# --app-name: Only toggle this specific app.

set -Eeuo pipefail

readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
app_name=""
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
		--app-name)
			app_name="$2"
			shift; shift;;
		*)
			shift;;
	esac; done
}

toggle_app_lock () {
	local apps_list=(
		"ares"
		"Azahar"
		"Brave Browser"
		"Bruno"
		"Docker"
		"Orion"
		"Google Chrome"
		"melonDS"
		"OBS"
		"Signal"
		"SkyEmu"
		"Spotify"
		"Visual Studio Code"
		"WhatsApp"
		"Xenia-edge"
		"Zed"
		"Zoom"
	)
	[[ -n $app_name ]] && apps_list=("$app_name")

	for app in "${apps_list[@]}"; do
		local app_path="/Applications/${app}.app"
		[[ ! -d $app_path ]] && continue;

		local app_flags="$(stdo=1 run stat -f '%Sf' "$app_path")"

		if  echo "$app_flags" | run grep -q -E "schg|uchg"; then
			log "Unlocking $app ..."
			run sudo chflags -R noschg "$app_path"
			run chflags -R nouchg "$app_path"
		else
			log "Locking $app ..."
			run sudo chflags -R schg "$app_path"
			run chflags -R uchg "$app_path"
		fi
	done
}

trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"
toggle_app_lock
log "Done!"
