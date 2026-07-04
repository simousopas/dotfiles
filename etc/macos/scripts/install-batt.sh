#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

trap_exit () {
	rm -rf "${TMPDIR}batt"
}
trap trap_exit EXIT

download_dir="${TMPDIR}batt"
install_dir="$HOME/.local/bin"
version=""
while [[ $# -gt 0 ]]; do case $1 in
	--version)
		version="$2";
		shift; shift;;
	*)
		shift;;
esac; done

	if [ -z "$version" ]; then
		echo "-> Querying batt's latest available version ..."
		version=$(
			curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
				--show-error --silent \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/charlie0129/batt/releases/latest" |
			jq --raw-output '.name'
		)
		echo "-> Latest available version is ${version}"
	fi

	url="https://github.com/charlie0129/batt/releases/download/${version}/batt-${version}-darwin-arm64.tar.gz"
	echo "-> Downloading $url ..."
	mkdir -p "$download_dir"
	curl --connect-timeout 13 --fail --location --progress-bar \
		--retry 5 --retry-delay 2 --show-error \
		--output "$download_dir/batt.tar.gz" \
		"$url"

	echo "-> Extracting $download_dir/batt.tar.gz ..."
	tar --directory "$download_dir" -xvf "$download_dir/batt.tar.gz" &>/dev/null

	launch_daemon="/Library/LaunchDaemons/cc.chlc.batt.plist"
	if [ -f "$launch_daemon" ]; then
		echo "-> Stopping launch daemon ..."
		sudo launchctl unload "$launch_daemon"
		sudo rm -rf "$launch_daemon"
	fi

	echo "-> Installing in $install_dir ..."
	rm -rf "$install_dir/batt"
	mv "$download_dir/batt" "$install_dir"
	sudo batt install --allow-non-root-access

	echo "-> Finished."
