#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -e

mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../" && pwd)"
pushd "$mydir" >/dev/null
trap "popd >/dev/null" EXIT

source "$root_dir/etc/scripts/helper.sh"
trap "popd >/dev/null; trap_error" ERR

cp "$root_dir/etc/macos/.bash_profile" "$TMPDIR/"
sed -i '' "s|#EXTERNAL_VOLUME||" "$TMPDIR/.bash_profile"
mv "$TMPDIR/.bash_profile" "$HOME/"
ln -fs "$HOME/.bash_profile" "$HOME/.bashrc"
# shellcheck disable=SC1091
source "$HOME/.bash_profile" || true

expected_hostname="macmini-m2pro"
if [ "$expected_hostname" != "$SHORT_HOSTNAME" ]; then
	log_warning ">>> This configuration script belongs to another host: $expected_hostname".
	log_warning ">>> The current host is: $SHORT_HOSTNAME"
	exit 1
fi

mkdir -p \
"$HOME"/{.bash_completion.d,.gnupg,.local/{bin,share/lf},.ssh/sockets} \
"$HOME"/.local/{bin,share/lf} \
"$HOME"/Library/{KeyBindings,LaunchAgents} \
"$HOME"/Library/Application\ Support/Code/User \
"$HOME"/Library/Application\ Support/com.nuebling.mac-mouse-fix \
"$HOME"/Library/Application\ Support/obs-studio/basic \
"$XDG_CACHE_HOME"/bun/{bin,cache-install,cache-transpiler,lib} \
"$XDG_CACHE_HOME"/code/{data/User,extensions} \
"$XDG_CACHE_HOME"/deno/bin \
"$XDG_CACHE_HOME"/{container,lima} \
"$XDG_CONFIG_HOME"/{bat/themes,fd,fish/completions} \
"$XDG_CONFIG_HOME"/{ghostty,git,lf,lima,mise,nvim,pip,rg,zed} \
"$CODE"/{github,simousopas} \
"$DOCUMENTS"/{Captures,Misc,Remote,UTM} \
"$DOWNLOADS"/{Brave,Misc,Safari,Torrents}

app_support_folder="$HOME/Library/Application Support"
vscode_cache_dir="$XDG_CACHE_HOME/code/data/User"
vscode_settings_dir="$app_support_folder/Code/User"

rm -rf "$HOME/.gnupg/gpg.conf"
rm -rf "$XDG_CONFIG_HOME/nvim/"*
cp "$root_dir/etc/.bash_completion" "$HOME/"
cp "$root_dir/etc/.inputrc" "$HOME/"
cp "$root_dir/etc/git.config" "$XDG_CONFIG_HOME/git/config"
cp "$root_dir/etc/gpg.conf" "$HOME/.gnupg/"
cp "$root_dir/etc/fdignore" "$XDG_CONFIG_HOME/fd/ignore"
cp "$root_dir/etc/keybindings.vscode.json" "$vscode_cache_dir/keybindings.json"
cp "$root_dir/etc/keybindings.vscode.json" "$vscode_settings_dir/keybindings.json"
cp "$root_dir/etc/lficons" "$XDG_CONFIG_HOME/lf/icons"
cp "$root_dir/etc/lfpreview" "$HOME/.local/bin/"
cp "$root_dir/etc/init.lua" "$XDG_CONFIG_HOME/nvim/"
cp "$root_dir/etc/obs-mask.png" "$DOCUMENTS/Misc/"
cp "$root_dir/etc/pip.conf" "$XDG_CONFIG_HOME/pip/"
cp "$root_dir/etc/rgignore" "$XDG_CONFIG_HOME/rg/ignore"
cp "$root_dir/etc/ssh.conf" "$HOME/.ssh/config"
cp "$root_dir/etc/tokyonight-moon.tmTheme" "$XDG_CONFIG_HOME/bat/themes"
cp "$root_dir/etc/zed.keymap.json" "$XDG_CONFIG_HOME/zed/keymap.json"
cp "$root_dir/etc/macos/config.fish" "$XDG_CONFIG_HOME/fish/"
cp "$root_dir/etc/macos/lfrc" "$XDG_CONFIG_HOME/lf/"
cp etc/mise.toml "$XDG_CONFIG_HOME/mise/config.toml"

rm -rf "$app_support_folder/obs-studio/basic/"*
cp -R etc/obs/* "$app_support_folder/obs-studio/basic"

chmod u=rwx,g=,o= "$HOME/.gnupg"
chmod u=r,g=,o= "$HOME/.gnupg/gpg.conf"
chmod u=rwx,g=,o= "$HOME/.ssh"
chmod u=rwx,g=,o= "$HOME/.ssh/sockets"
chmod u+x "$HOME/.local/bin/lfpreview"
sed -i '' "s|#EXTERNAL_VOLUME||" "$XDG_CONFIG_HOME/fish/config.fish"
sed -i '' "s|#LIMA_HOME|$XDG_CONFIG_HOME/lima|" "$HOME/.bash_profile"
sed -i '' "s|#LIMA_HOME|$XDG_CONFIG_HOME/lima|" "$XDG_CONFIG_HOME/fish/config.fish"
ln -fhs "$XDG_CACHE_HOME/container" "$HOME/Library/Application Support/com.apple.container"
ln -fhs "$XDG_CACHE_HOME/lima" "$HOME/Library/Caches/lima"

touch "$HOME/.bash_sessions_disable"
touch "$HOME/.hushlogin"
touch "$XDG_CONFIG_HOME/lf/bookmarks"

source "$root_dir/etc/macos/scripts/export-defaults.sh" --source-keys-only
defaults import "$actmon_key" "$actmon_file"
defaults import "$alttab_key" "$alttab_file"
defaults import "$betterdisplay_key" "$betterdisplay_file"
cp "$macmousefix_file" "$app_support_folder/com.nuebling.mac-mouse-fix/config.plist"

# This section is reserved for files that must be patched before being installed.
# ===============================================================================

if [ -n "$HOMEBREW_PREFIX" ]; then
	zed_extensions="$(cat etc/zed.extensions.json)"
	export bun_cache_dir="$XDG_CACHE_HOME/bun/cache-install"
	export bun_global_bindir="$XDG_CACHE_HOME/bun/bin"
	export bun_global_dir="$XDG_CACHE_HOME/bun/lib"
	export font_size="11"
	export terminal_window_height="35"
	export terminal_window_width="150"
	export zed_extensions
	rm -rf "$HOME/.gnupg/gpg-agent.conf"
	envsubst <"$root_dir/etc/macos/.bunfig.toml" >"$XDG_CONFIG_HOME/.bunfig.toml"
	envsubst <"$root_dir/etc/macos/ghostty.conf" >"$XDG_CONFIG_HOME/ghostty/config"
	envsubst <"$root_dir/etc/macos/lfmarks" >"$HOME/.local/share/lf/marks"
	envsubst <"$root_dir/etc/gpg-agent.conf" >"$HOME/.gnupg/gpg-agent.conf"
	envsubst <"$root_dir/etc/settings.vscode.json" >"$TMPDIR/settings.vscode.json"
	envsubst <"$root_dir/etc/zed.settings.json" >"$XDG_CONFIG_HOME/zed/settings.json"
	cp "$TMPDIR/settings.vscode.json" "$vscode_cache_dir/settings.json"
	cp "$TMPDIR/settings.vscode.json" "$vscode_settings_dir/settings.json"
	rm "$TMPDIR/settings.vscode.json"
	chmod u=r,g=,o= "$HOME/.gnupg/gpg-agent.conf"
fi
