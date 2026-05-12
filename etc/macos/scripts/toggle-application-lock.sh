#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR
# shellcheck disable=SC2155

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

action="lock"
while [[ $# -gt 0 ]]; do case $1 in
	--lock)
		action="lock";
		shift;;
	--unlock)
		action="unlock";
		shift;;
	*)
		shift;;
esac; done

apps_list=(
	"ares"
	"Azahar"
	"Brave Browser"
	"Bruno"
	"Docker"
	"Orion"
	"Google Chrome"
	"melonDS"
	"OBS"
	"Signal"
	"SkyEmu"
	"Spotify"
	"Visual Studio Code"
	"WhatsApp"
	"Zed"
	"Zoom"
)

[ "$action" != "lock" ] && [ "$action" != "unlock" ] &&
	echo "Error: No specific action was select: --lock/--unlock." &&
	exit 1

[ "$action" == "lock" ] &&
	sflags="schange" && uflags="uchange" &&
	echo "-> Locking applications ..."
[ "$action" == "unlock" ] &&
	sflags="noschange" && uflags="nouchange" &&
	echo "-> Unlocking applications ..."

for item in "${apps_list[@]}"; do
	app="/Applications/${item}.app"
	if [ -d "$app" ]; then
		echo -e "\t-> ${action}ing $item ..."
		sudo chflags -R "$sflags" "/Applications/${item}.app"
		chflags -R "$uflags" "/Applications/${item}.app"
	fi
done

echo "-> All done!"
