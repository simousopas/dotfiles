#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

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
	rm -rf "$TMPDIR/hosts"
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

trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"


log "Adding entries ..."
stdo=1 run echo "\
127.0.0.1 localhost
127.0.0.1 localhost.localdomain
127.0.0.1 local
127.0.0.1 ${HOSTNAME/%.local/}
127.0.0.1 ${HOSTNAME/%.local/}.localdomain
255.255.255.255 broadcasthost
::1 localhost
::1 ip6-localhost
::1 ip6-loopback
fe80::1%lo0 localhost
ff00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
0.0.0.0 0.0.0.0" >>"$TMPDIR/hosts"

log "Overwriting /private/etc/hosts ..."
run sudo mv "$TMPDIR/hosts" "/private/etc/hosts"

log "Flushing the DNS cache ..."
run sudo dscacheutil -flushcache
run sudo killall mDNSResponder

log "Done!"
