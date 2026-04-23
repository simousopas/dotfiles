#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

trap_exit () {
	rm -rf "${TMPDIR}iSMC"
}
trap trap_exit EXIT

download_dir="${TMPDIR}iSMC"
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
		echo "-> Querying iSMC latest available version ..."
		version=$(
			curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
				--show-error --silent \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/dkorunic/iSMC/releases/latest" |
			jq --raw-output '.name'
		)
	fi

	url="https://github.com/dkorunic/iSMC/releases/download/${version}/iSMC_Darwin_all.tar.gz"
	echo "-> Downloading $url ..."
	mkdir -p "$download_dir"
	curl --connect-timeout 13 --fail --location --progress-bar \
		--retry 5 --retry-delay 2 --show-error \
		--output "$download_dir/iSMC.tar.gz" \
		"$url"

	echo "-> Extracting $download_dir/iSMC.tar.gz ..."
	tar --directory "$download_dir" -xvf "$download_dir/iSMC.tar.gz" &>/dev/null

	echo "-> Installing in $install_dir ..."
	rm -rf "$install_dir/iSMC"
	mv "$download_dir/iSMC" "$install_dir"

	echo "-> Finished."
