#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script exports a bunch of application settings. Exported settings can be
# saved and restored at later stage.
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
source_envvars_only=0
verbose=0

short_hostname="${HOSTNAME/%.local/}"
[[ $short_hostname == vm-macos13-ventura* ]] && short_hostname="vm-macos13-ventura"
[[ $short_hostname == vm-macos14-sonoma* ]] && short_hostname="vm-macos14-sonoma"
[[ $short_hostname == vm-macos15-sequoia* ]] && short_hostname="vm-macos15-sequoia"
[[ $short_hostname == vm-macos26-tahoe* ]] && short_hostname="vm-macos26-tahoe"
[[ $short_hostname == vm-macos27-goldengate* ]] && short_hostname="vm-macos27-goldengate"
readonly HOST_DIR="$ROOT_DIR/macos/$short_hostname"

readonly ACTMON_KEY="com.apple.ActivityMonitor"
readonly ACTMON_FILE="$HOST_DIR/etc/${ACTMON_KEY}.plist"
readonly ALTTAB_KEY="com.lwouis.alt-tab-macos"
readonly ALTTAB_FILE="$ROOT_DIR/etc/macos/${ALTTAB_KEY}.plist"
readonly BETTERDISPLAY_KEY="pro.betterdisplay.BetterDisplay"
readonly BETTERDISPLAY_FILE="$HOST_DIR/etc/${BETTERDISPLAY_KEY}.plist"
readonly MACMOUSEFIX_KEY="com.nuebling.mac-mouse-fix"
readonly MACMOUSEFIX_FILE="$ROOT_DIR/etc/macos/${MACMOUSEFIX_KEY}.plist"
readonly MACMOUSEFIX_FILE_SOURCE="$HOME/Library/Application Support/${MACMOUSEFIX_KEY}/config.plist"
readonly OBS_DIR="$HOST_DIR/etc/obs/"
readonly OBS_DIR_SOURCE="$HOME/Library/Application Support/obs-studio/basic"
# readonly RECTANGLE_KEY="com.knollsoft.Rectangle"
# readonly RECTANGLE_FILE="$ROOT_DIR/etc/macos/${RECTANGLE_KEY}.plist"
# readonly RECTANGLE_CHORDS_KEY="com.knollsoft.Hookshot"
# readonly RECTANGLE_CHORDS_FILE="$ROOT_DIR/etc/macos/${RECTANGLE_CHORDS_KEY}.plist"

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
		--source-envvars-only)
			source_envvars_only=1
			shift;;
		*)
			shift;;
	esac; done
}

export_apps_settings () {
	log "Exporting Activity Monitor settings ..."
	run defaults export "$ACTMON_KEY" "$ACTMON_FILE"
	log "Exporting AltTab settings ..."
	run defaults export "$ALTTAB_KEY" "$ALTTAB_FILE"
	log "Exporting Betterdisplay settings ..."
	run defaults export "$BETTERDISPLAY_KEY" "$BETTERDISPLAY_FILE"
	if [[ -f $MACMOUSEFIX_FILE_SOURCE ]]; then
		log "Exporting Mac Mouse Fix settings ..."
		run cp "$MACMOUSEFIX_FILE_SOURCE" "$MACMOUSEFIX_FILE"
	fi
	if [[ -d $OBS_DIR_SOURCE ]]; then
		log "Exporting OBS settings ..."
		run rm -rf "$OBS_DIR"
		run cp -R "$OBS_DIR_SOURCE" "$OBS_DIR"
		run find "$OBS_DIR" -name "*.bak" -type f -delete
	fi
	# log "Exporting Rectangle settings ..."
	# run defaults export "$RECTANGLE_KEY" "$RECTANGLE_FILE"
	# log "Exporting Rectangle chord settings ..."
	# run defaults export "$RECTANGLE_CHORDS_KEY" "$RECTANGLE_CHORDS_FILE"
}

trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"
log "Environment variables sourced."
[[ $source_envvars_only == 0 ]] && export_apps_settings
log "Done!"
