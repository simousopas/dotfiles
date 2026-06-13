#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

silent=""
url="https://github.com/AsahiLinux/macvdmtool.git"
while [[ $# -gt 0 ]]; do case $1 in
	--silent)
		silent="true"
		shift;;
	*)
		shift;;
esac; done

clean_install () {
	echo "-> Cloning macvdmtool ..."
	_run git clone "$url" "$CODE/github/macvdmtool"

	echo "-> Building and installing macvdmtool ..."
	pushd "$CODE/github/macvdmtool" >/dev/null
	_run make 2> /dev/null
	mv macvdmtool "$HOME/.local/bin/macvdmtool"
	popd >/dev/null

	echo "-> Done!"
}

update_preexisting () {
	echo "-> Updating preexisting setup ..."
	pushd "$CODE/github/macvdmtool" >/dev/null

	echo "-> Pulling the lastest version ..."
	_run git clean -fddx
	_run git pull --prune

	echo "-> Building and installing macvdmtool ..."
	_run make 2> /dev/null
	mv macvdmtool "$HOME/.local/bin/macvdmtool"
	popd >/dev/null

	echo "-> Done!"
}

if [ -d "$CODE/github/macvdmtool" ]; then
	update_preexisting
else
	clean_install
fi
