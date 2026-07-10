#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

# README
# This script automatically sets up /private/etc/host
#
# Pre-conditions:
# - `curl` must be installed in case you whish to pull Steven Black's hosts.
#
# The following switches are available:
# --with-sb-hosts-variant: Select a particular variant of Steven Black's hosts
#   to be installed. By default it will be the base 'Unifiedd' variant. Oher
#   variants can be found here: https://github.com/StevenBlack/hosts#list-of-all-hosts-file-variants
# --with-sb-hosts-version: Select a particular release of Steven Black's hosts
#   to be installed. By default it will be the latest one. Other versions can be
#   found here: https://github.com/StevenBlack/hosts/releases
# -v: Print major commands being executed.
# -vv: Print major commands being executed and their output.

set -Eeuo pipefail

readonly SB_HOSTS_REPO="StevenBlack/hosts"
readonly TMP_LOG_FILE="$TMPDIR/${0##*/}.log"
sb_hosts_variant=""
sb_hosts_version=""
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
	rm -rf "$TMPDIR/sb-hosts"
}

parse_input_args () {
	while [[ $# -gt 0 ]]; do case $1 in
		--with-sb-hosts-variant)
			sb_hosts_variant="$2";
			shift; shift;;
		--with-sb-hosts-version)
			sb_hosts_version="$2";
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
	log "Checking pre-conditions ..."

	if [[ -n $sb_hosts_variant || -n $sb_hosts_version ]] && ! which -s curl; then
		err "\`curl\` was not found but it's required by this script when pulling Steven Black's hosts."
		exit 1
	fi
}

add_basic_hosts () {
	log "Adding basic entries ..."
	{
		stdo=1 run echo "# Start: Basic hosts";
		stdo=1 run echo "127.0.0.1 localhost";
		stdo=1 run echo "127.0.0.1 localhost.localdomain";
		stdo=1 run echo "127.0.0.1 local"
		stdo=1 run echo "127.0.0.1 ${HOSTNAME/%.local/}"
		stdo=1 run echo "127.0.0.1 ${HOSTNAME/%.local/}.localdomain"
		stdo=1 run echo "255.255.255.255 broadcasthost"
		stdo=1 run echo "::1 localhost"
		stdo=1 run echo "::1 ip6-localhost"
		stdo=1 run echo "::1 ip6-loopback"
		stdo=1 run echo "fe80::1%lo0 localhost"
		stdo=1 run echo "ff00::0 ip6-localnet"
		stdo=1 run echo "ff00::0 ip6-mcastprefix"
		stdo=1 run echo "ff02::1 ip6-allnodes"
		stdo=1 run echo "ff02::2 ip6-allrouters"
		stdo=1 run echo "ff02::3 ip6-allhosts"
		echo ""
	}>>"$TMPDIR/hosts"
}

add_stevenblack_hosts () {
	if [[ -z $sb_hosts_variant && -z $sb_hosts_version ]]; then
		return 0
	fi

	if [[ -z $sb_hosts_version || $sb_hosts_version == "latest" ]]; then
		log "Querying StevenBlack's hosts latest available version ..."
		sb_hosts_version=$(
			stdo=1 run curl --fail --location --show-error --silent \
				--connect-timeout 13  --retry 5 --retry-delay 2 \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/$SB_HOSTS_REPO/releases/latest" |
			stdo=1 run jq --raw-output '.tag_name'
		)
		log "The latest available version is $sb_hosts_version"
	fi

	log "Downloading StevenBlack's hosts ..."
	local sb_hosts_url=""
	if [[ -z $sb_hosts_variant || $sb_hosts_variant == "unified" ]]; then
		sb_hosts_url="https://raw.githubusercontent.com/$SB_HOSTS_REPO/${sb_hosts_version}/hosts"
	else
		sb_hosts_url="https://raw.githubusercontent.com/$SB_HOSTS_REPO/${sb_hosts_version}/alternates/{$sb_hosts_variant}/hosts"
	fi
	stdo=1 run curl --fail --location --show-error --silent \
		--connect-timeout 13  --retry 5 --retry-delay 2 \
		--header "Accept:application/vnd.github.v3.raw" \
		--output "$TMPDIR/sb-hosts" \
		"$sb_hosts_url"

	log "Parsing and merging StevenBlack's hosts ..."
	stdo=1 run sed '1,/^# End of custom host records.$/d' "$TMPDIR/sb-hosts" >>"$TMPDIR/hosts"
}


trap 'cleanup EXIT' EXIT
trap 'cleanup ERR' ERR
parse_input_args "$@"
check_preconds
add_basic_hosts
add_stevenblack_hosts

log "Overwriting /private/etc/hosts ..."
run sudo mv "$TMPDIR/hosts" "/private/etc/hosts"

log "Flushing the DNS cache ..."
run sudo dscacheutil -flushcache
run sudo killall mDNSResponder

log "Done!"
