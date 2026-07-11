#!/usr/bin/env bash
# shellcheck disable=SC2155

# README
# Enables a fundamental set of system services used to run updates in a macOS system.
# Once finished with the maintenance, run the appropriate disable-service-*.sh script.

set -Eeuo pipefail

readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
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
		*)
			shift;;
	esac; done
}

enable_maintenane_services () {
	log "Enabling user services ..."
	local uid=$(id -u)
	run launchctl enable "gui/$uid/com.apple.appstoreagent"
	run launchctl enable "gui/$uid/com.apple.appstorecomponentsd"
	run launchctl enable "gui/$uid/com.apple.SoftwareUpdateNotificationManager"

	log "Enabling system services ..."
	local macos_major_version="$(sw_vers -productVersion | grep -o '^\d*')"
	if [ $((macos_major_version)) -ne 26 ]; then
		run sudo launchctl enable "system/com.apple.security.syspolicy"
	fi
	run sudo launchctl enable "system/com.apple.appstored"
	run sudo launchctl enable "system/com.apple.AppStoreDaemon.StorePrivilegedODRService"
	run sudo launchctl enable "system/com.apple.AppStoreDaemon.StorePrivilegedTaskService"
	run sudo launchctl enable "system/com.apple.dasd"
	run sudo launchctl enable "system/com.apple.mobile.softwareupdated"
	run sudo launchctl enable "system/com.apple.softwareupdated"
}

trap 'cleanup ERR' ERR
trap 'cleanup EXIT' EXIT
parse_input_args "$@"
enable_maintenane_services
