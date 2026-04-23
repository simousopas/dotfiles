#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2129
# shellcheck disable=SC2207

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../" && pwd)"
trap 'rm -rf $TMPDIR/hosts*' EXIT

source "$root_dir/etc/scripts/helper.sh"
trap 'trap_error; rm -rf $TMPDIR/hosts*' ERR

skip_optional_blacklist="no"
skip_optional_whitelist="no"
force_hostname=""
system="$(uname -s)"
version=""
url=""

while [[ $# -gt 0 ]]; do case $1 in
	--force-hostname)
		force_hostname="$2";
		shift; shift;;
	--skip-optional-blacklist)
		skip_optional_blacklist="yes";
		shift;;
	--skip-optional-whitelist)
		skip_optional_whitelist="yes";
		shift;;
	--version)
		version="$2";
		shift; shift;;
	*)
		shift;;
esac; done


if [ -z "$version" ]; then
	echo "-> Querying StevenBlack's hosts latest available version ..."
	version=$(
		curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
			--show-error --silent \
			--header "Accept:application/vnd.github.v3.raw" \
			"https://api.github.com/repos/StevenBlack/hosts/releases/latest" |
		jq --raw-output '.tag_name'
	)
fi

url="https://raw.githubusercontent.com/StevenBlack/hosts/${version}/hosts"

if [ "$system" = "Darwin" ]; then

	echo "-> Downloading StevenBlack's hosts v$version ..."
	curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
		--show-error --silent --header "Accept:application/vnd.github.v3.raw" \
		--output "$TMPDIR/hosts" \
		"$url"

	echo "-> Blacklisting domains ..."

	hosts_blacklist_orig="$root_dir/etc/scripts/install-hosts-blacklist.json"
	hosts_whitelist_orig="$root_dir/etc/scripts/install-hosts-whitelist.json"
	hosts_blacklist="${TMPDIR}hosts-blacklist.json"
	export _hostname="${force_hostname:-$SHORT_HOSTNAME}"
	envsubst <"$hosts_blacklist_orig" >"$hosts_blacklist"

	echo "" >>"$TMPDIR/hosts"
	echo "# START --- General blacklist" >>"$TMPDIR/hosts"
	declare -a shared_address_list=($(
		jq --raw-output '.shared | keys[]' "$hosts_blacklist" |
		tr "\n" " "
	))
	for addr in "${shared_address_list[@]}"; do
		declare -a shared_names_list=($(
			jq --raw-output ".shared[\"$addr\"][]" "$hosts_blacklist" |
			tr "\n" " "
		))
		for name in "${shared_names_list[@]}"; do
			echo -e "\t-> Setting $name :: $addr"
			echo "$addr $name" >>"$TMPDIR/hosts"
		done
	done
	declare -a shared_address_list=($(
		jq --raw-output '.shared_optional| keys[]' "$hosts_blacklist" |
		tr "\n" " "
	))
	if [ $skip_optional_blacklist = "no" ]; then
		for addr in "${shared_address_list[@]}"; do
			declare -a shared_names_list=($(
				jq --raw-output ".shared_optional[\"$addr\"][]" "$hosts_blacklist" |
				tr "\n" " "
			))
			for name in "${shared_names_list[@]}"; do
				echo -e "\t-> Setting $name :: $addr"
				echo "$addr $name" >>"$TMPDIR/hosts"
			done
		done
	fi
	echo "# END --- General blacklist" >>"$TMPDIR/hosts"

	echo "" >>"$TMPDIR/hosts"
	echo "# START --- Specific blacklist for $_hostname" >>"$TMPDIR/hosts"
	declare -a specific_address_list=($(
		jq --raw-output ".specific.\"${_hostname}\" | keys[]" "$hosts_blacklist" |
		tr "\n" " "
	))
	for addr in "${specific_address_list[@]}"; do
		if [ -z "$addr" ]; then continue; fi
		declare -a specific_names_list=($(
			jq --raw-output ".specific.\"$_hostname\"[\"$addr\"][]" "$hosts_blacklist" |
			tr "\n" " "
		))
		for name in "${specific_names_list[@]}"; do
			echo -e "\t-> Including $addr:$name ..."
			echo "$addr $name" >>"$TMPDIR/hosts"
		done
	done
	echo "# END --- Specific blacklist for $_hostname" >>"$TMPDIR/hosts"

	echo "-> Whitelisting domains ..."

	declare -a shared_address_list=($(
		if [ $skip_optional_whitelist = "no" ]; then
			shared_filter=".shared+.shared_optional|.[]"
		else
			shared_filter=".shared|.[]"
		fi
		jq --raw-output "$shared_filter" "$hosts_whitelist_orig" |
		tr "\n" " "
	))
	for name in "${shared_address_list[@]}"; do
		if [ -z "$name" ]; then continue; fi
		echo -e "\t-> $name ..."
		sed -i '' -r "/$name/s//# &/" "$TMPDIR/hosts"
	done

	declare -a specific_address_list=($(
		jq --raw-output ".specific.\"$_hostname\"[]" "$hosts_whitelist_orig" |
		tr "\n" " "
	))
	for name in "${specific_address_list[@]}"; do
		if [ -z "$name" ]; then continue; fi
		echo -e "\t-> $name ..."
		sed -i '' -r "/$name/s//# &/" "$TMPDIR/hosts"
	done

	echo "-> Overwriting /private/etc/hosts ..."
	sudo mv "$TMPDIR/hosts" /private/etc/hosts

	echo "-> Restarting mDNSResponder ..."
	sudo killall mDNSResponder

	echo "-> Done!"

elif [ "$system" = "Linux" ]; then
	#TODO
	:
fi
