#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -e
mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../" && pwd)"

source "$root_dir/etc/scripts/helper.sh"
trap trap_error ERR

plugins_list=""
silent=""
while [[ $# -gt 0 ]]; do case $1 in
	--plugins-list)
		plugins_list="$2";
		shift;;
	--silent)
		silent="yes";
		shift;;
	*)
		shift;;
esac; done

vsc_data_dir="$XDG_CACHE_HOME/code/data/"
vsc_extensions_dir="$XDG_CACHE_HOME/code/extensions/"
vsc_extensions_list_queue="${TMPDIR}vscode.plugins.txt"

if [ -f "$vsc_extensions_list_queue" ]; then
	vsc_extensions_list=$(cat "$vsc_extensions_list_queue")
else
	vsc_extensions_list=$(cat "$plugins_list")
	echo "$vsc_extensions_list" >"$vsc_extensions_list_queue"
fi

for extension in $vsc_extensions_list
do
	extension_author=${extension%%*.}
	extension_name=${extension##*.}
	echo "-> Installing $extension_name of $extension_author"
	_run code \
		--user-data-dir "$vsc_data_dir" \
		--extensions-dir "$vsc_extensions_dir" \
		--install-extension "$extension" \
		--force

	# Remove the last extension that was successfully installed so it won't be
	# reprocessed when the script is re-ran after a failure.
	sed -i '' '1d' "$vsc_extensions_list_queue"

done

rm "$vsc_extensions_list_queue"
