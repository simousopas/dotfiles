#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap 'rm -rf "$TMPDIR/vcpkg"; [[ ${#DIRSTACK[@]} -gt 1 ]] && popd >/dev/null; trap_error' ERR
trap 'rm -rf "$TMPDIR/vcpkg"' EXIT

silent=""
tag=""
url="https://github.com/microsoft/vcpkg.git"
while [[ $# -gt 0 ]]; do case $1 in
	--silent)
		silent="&>/dev/null"
		shift;;
	--tag)
		tag="$2";
		shift; shift;;
	*)
		shift;;
esac; done

clean_install () {
	echo "-> Cloning vcpkg @$tag ..."
	_run git clone --branch "$tag" "$url" "$TMPDIR/vcpkg"

	echo "-> Bootstrapping vcpkg ..."
	cd "$TMPDIR/vcpkg" && _run ./bootstrap-vcpkg.sh && cd - &>/dev/null

	echo "-> Installing vcpkg ..."
	[ -d "$VCPKG_ROOT" ] && rm -rf "$VCPKG_ROOT"
	mv "$TMPDIR/vcpkg" "$VCPKG_ROOT"
	ln -sf "$VCPKG_ROOT/vcpkg" ~/.local/bin/vcpkg

	echo "-> Done!"
}

update_preexisting () {
	echo "-> Updating preexisting setup @$tag ..."
	pushd "$VCPKG_ROOT" >/dev/null
	_run git checkout master
	_run git pull --prune
	_run git checkout "$tag"

	echo "-> Bootstrapping and installing vcpkg ..."
	_run ./bootstrap-vcpkg.sh
	ln -sf "$VCPKG_ROOT/vcpkg" ~/.local/bin/vcpkg

	popd >/dev/null
	echo "-> Done!"
}

if [ -z "$tag" ]; then
	echo "-> Querying vcpkg latest available version ..."
	tag=$(
		curl --connect-timeout 13 --fail --location --retry 5 --retry-delay 2 \
			--show-error --silent \
			--header "Accept:application/vnd.github.v3.raw" \
			"https://api.github.com/repos/microsoft/vcpkg/releases/latest" |
		jq --raw-output '.tag_name'
	)
fi

if [ -d "$VCPKG_ROOT" ]; then
	update_preexisting
else
	clean_install
fi
