#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

trap_exit () {
	rm -rf "${TMPDIR}mongodb"*
	rm -rf "${TMPDIR}mongosh"*
}
trap trap_exit EXIT

arch="$(uname -m)"
system="$(uname -s)"
target="$1"
version=""
shift;

while [[ $# -gt 0 ]]; do case $1 in
	--version)
		version="$2";
		shift; shift;;
	*)
		shift;;
esac; done

if [ "$target" == "shell" ]; then

	if [ -z "$version" ]; then
		echo "-> Querying MongoDB Shell latest available version ..."
		version=$(
			curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
				--show-error --silent \
				--header "Accept:application/vnd.github.v3.raw" \
				"https://api.github.com/repos/mongodb-js/mongosh/releases/latest" |
			jq --raw-output '.name'
		)
	fi

	# This could just be a simple `brew install mongosh` but it has an uncessary
	# dependecy on Node.js/NPM.
	if [ "$system" = "Darwin" ]; then

		if [ "$arch" = "x86_64" ]; then arch="x64"; fi
		url="https://github.com/mongodb-js/mongosh/releases/download/v${version}/mongosh-${version}-darwin-${arch}.zip"

		echo "-> Downloading $url ..."
		curl --connect-timeout 13 --fail --location --progress-bar \
			--retry 5 --retry-delay 2 --show-error \
			--output "${TMPDIR}mongosh.zip" \
			"$url"

		echo "-> Extracting ${TMPDIR}mongosh.zip ..."
		unzip "${TMPDIR}mongosh.zip" -d "$TMPDIR" >/dev/null

		echo "-> Installing in $HOME/.local/bin/ ..."
		rm -rf "$HOME/.local/bin/mongosh"
		mv "${TMPDIR}mongosh-${version}-darwin-${arch}/bin/mongosh" "$HOME/.local/bin/"

		echo "-> Finished."

	elif [ "$system" = "Linux" ]; then
		# TODO
		:
	fi

elif [ "$target" == "tools" ]; then

	if [ -z "$version" ]; then
		version="100.17.0"
	fi

	if [ "$system" = "Darwin" ]; then
		url="https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-${arch}-${version}.zip"
		echo "-> Downloading $url ..."
		curl --connect-timeout 13 --fail --location --progress-bar \
			--retry 5 --retry-delay 2 --show-error \
			--output "${TMPDIR}mongodb-tools.zip" \
			"$url"

		echo "-> Extracting ${TMPDIR}mongodb-tools.zip ..."
		unzip "${TMPDIR}mongodb-tools.zip" -d "$TMPDIR" >/dev/null

		echo "-> Installing in $HOME/.local/bin/ ..."
		rm -rf "$HOME/.local/bin"/mongo{dump,export,files,import,restore,stat,top}
		mv "${TMPDIR}mongodb-database-tools-macos-${arch}-${version}/bin/mongo"* "$HOME/.local/bin/"

		echo "-> Finished."

	elif [ "$system" = "Linux" ]; then
		# TODO
		:
	fi
fi
