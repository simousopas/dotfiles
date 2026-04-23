#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

trap_exit () {
	rm -rf "${TMPDIR}${app_name}"
}
trap trap_exit EXIT

app_name="SkyEmu"
download_dir="${TMPDIR}${app_name}"
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
	echo "-> Uninstalling $app_name ..."
	rm -rf /Applications/${app_name}.app
	rm -rf "$HOME/Library/Application Support/Sky/${app_name}"
	echo "-> Finished."
	exit 0
fi

if [ -z "$version" ]; then
	echo "-> Querying ${app_name}'s latest available version ..."
	version=$(
		curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
			--show-error --silent \
			--header "Accept:application/vnd.github.v3.raw" \
			"https://api.github.com/repos/skylersaleh/${app_name}/releases/latest" |
		jq --raw-output '.name'
	)
	version=${version#* }
fi

url="https://github.com/skylersaleh/${app_name}/releases/download/${version}/${app_name}-${version}-macOS.dmg"
echo "-> Downloading $url ..."
mkdir -p "$download_dir"
curl --connect-timeout 13 --fail --location --progress-bar \
	--retry 5 --retry-delay 2 --show-error \
	--output "$download_dir/${app_name}.dmg" \
	"$url"

echo "-> Installing in $install_dir ..."
hdiutil attach "${download_dir}/${app_name}.dmg" &>/dev/null
rm -rf "${install_dir}/${app_name}.app"
cp -R "/Volumes/${app_name}/${app_name}.app" "$install_dir/"
umount "/Volumes/${app_name}"

echo "-> Finished."
