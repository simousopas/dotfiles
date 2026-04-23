#!/usr/bin/env bash
# shellcheck disable=SC1090

set -e

mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
pushd "$mydir" >/dev/null
trap "popd >/dev/null" EXIT

os="$(uname -s)"

if [ "$os" = "Darwin" ]; then
	nice_hostname="${HOSTNAME/%.local/}"
	[[ $nice_hostname == vm-macos13-ventura* ]] && nice_hostname="vm-macos13-ventura"
	[[ $nice_hostname == vm-macos14-sonoma* ]] && nice_hostname="vm-macos14-sonoma"
	[[ $nice_hostname == vm-macos15-sequoia* ]] && nice_hostname="vm-macos15-sequoia"
	[[ $nice_hostname == vm-macos26-tahoe* ]] && nice_hostname="vm-macos26-tahoe"
	. "./macos/$nice_hostname/configure.sh"
fi
