#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

trap_exit () {
	rm -rf "${TMPDIR}azahar"
}
trap trap_exit EXIT

download_dir="${TMPDIR}azahar"
install_dir="/Applications"
uninstall="false"
version=""
while [[ $# -gt 0 ]]; do case $1 in
	--uninstall)
		uninstall="true";
		shift;;
	--version)
		version="$2";
		shift; shift;;
	*)
		shift;;
esac; done

if [ "$uninstall" = "true" ]; then
	echo "-> Uninstalling Azahar ..."
	rm -rf /Applications/Azahar.app
	rm -rf "$HOME/Library/Application Support/Azahar"
	echo "-> Finished."
	exit 0
fi

if [ -z "$version" ]; then
	echo "-> Querying Azahar's latest available version ..."
	version=$(
		curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
			--show-error --silent \
			--header "Accept:application/vnd.github.v3.raw" \
			"https://api.github.com/repos/azahar-emu/azahar/releases/latest" |
		jq --raw-output '.name'
	)
	version=${version#* }
fi

arch="$(uname -m)"
url="https://github.com/azahar-emu/azahar/releases/download/${version}/azahar-macos-${arch}-${version}.zip"
echo "-> Downloading $url ..."
mkdir -p "$download_dir"
curl --connect-timeout 13 --fail --location --progress-bar \
	--retry 5 --retry-delay 2 --show-error \
	--output "$download_dir/azahar.zip" \
	"$url"

echo "-> Extracting $download_dir/azahar.zip ..."
unzip  "$download_dir/azahar.zip" -d "$download_dir" &>/dev/null

echo "-> Installing in $install_dir ..."
rm -rf "$install_dir/Azahar.app"
mv "$download_dir/azahar-macos-${arch}-$version/Azahar.app" "$install_dir"

echo "-> Finished."
