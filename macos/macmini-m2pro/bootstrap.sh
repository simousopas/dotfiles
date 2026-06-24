#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -e

mydir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
root_dir="$(cd "$mydir/../../" && pwd)"
pushd "$mydir" >/dev/null
trap "popd >/dev/null" EXIT

source "$root_dir/etc/scripts/helper.sh"
trap "popd >/dev/null; trap_error" ERR


xcode_cli_tools_path="$(xcode-select --print-path 2>/dev/null || true)"
if [ -d "$xcode_cli_tools_path" ]; then
	log_info "\t >>> XCode CLI Tools available at: $xcode_cli_tools_path"
else
	log_error "\t >>> XCode CLI Tools not available. Please install them first."
	exit 1
fi


bootstrap_finished="$HOME/.bootstrapped"
if [ -s "$bootstrap_finished" ]; then
	log_warning ">>> This system was already successfully bootstrapped."
	log_warning ">>> To restart the process: \$ rm $bootstrap_finished"
	exit 1
fi

expected_hostname="macmini-m2pro"
nice_hostname="${HOSTNAME/%.local/}"
if [ "$expected_hostname" != "$nice_hostname" ]; then
	log_warning ">>> This bootstrap script belongs to another host: $expected_hostname".
	log_warning ">>> The current host is: $nice_hostname"
	exit 1
fi

log_info "\t >>> Installing dotfiles"
/bin/bash configure.sh


log_info "\t >>> Configuring the Desktop and keyboard"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.dock autohide-delay -int 0
defaults write com.apple.dock autohide-time-modifier -float 0.30
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
defaults write -g NSWindowShouldDragOnGesture -bool true
killall Dock


log_info "\t >>> Installing Apple Rosetta"
/usr/sbin/softwareupdate --install-rosetta --agree-to-license


if [ -z "$(command -v brew)" ]; then
	log_info "\t >>> Installing Homebrew ..."
	homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
	/bin/bash -c "$(curl --fail --location --silent --show-error $homebrew_url)"
	source "$root_dir/etc/macos/.bash_profile" || true
fi


log_info "\t >>> Installing Homebrew command line tools ..."
homebrew_clt=(
	7zip aria2 bat bash bash-completion@2 bzip2 container coreutils eza fd fio
	fish fzf gettext git-delta gsed jq lf lima macmon miniserve mise neovim
	pbzip2 pigz pinentry ripgrep shellcheck tokei tree typst xz zstd
)
brew install "${homebrew_clt[@]}"
brew unlink openssl@3


log_info "\t >>> Installing Homebrew apps ..."
homebrew_casks=(
	alt-tab betterdisplay brave-browser bruno dbeaver-community
	font-jetbrains-mono-nerd-font fork geekbench ghostty iina mac-mouse-fix obs
	signal spotify transmission utm visual-studio-code visualdiffer zed
)
brew install --cask "${homebrew_casks[@]}"


log_info "\t >>> Sourcing environment variables and re-installing dotfiles"
source "$root_dir/etc/macos/.bash_profile" || true
/bin/bash configure.sh
bat cache --build
defaults write com.DanPristupov.Fork SUEnableAutomaticChecks 0
defaults write com.DanPristupov.Fork applicationUpdateChannel 1
defaults write com.DanPristupov.Fork defaultSourceFolder "$HOME/Developer"
defaults write com.DanPristupov.Fork fetchAllTags 0
defaults write com.DanPristupov.Fork fetchRemotesAutomatically 0
defaults write com.DanPristupov.Fork updateSubmodulesOnCheckout 0


log_info "\t >>> Setting up the hosts file ..."
/bin/bash "$root_dir/etc/scripts/install-hosts.sh"


log_info "\t >>> Installing pip packages ..."
pip3 install --user wheel
pip3 install --user pynvim


log_info "\t >>> Installing mise packages ..."
MISE_YES=1 mise install
# fish --command "bun completions"


log_info "\t >>> Installing iSMC ..."
/bin/bash "$root_dir/etc/macos/scripts/install-ismc.sh"
ismc completion bash >"$HOME/.bash_completion.d/iscm.sh"
ismc completion fish >"$XDG_CONFIG_HOME/fish/completions/ismc.fish"


log_info "\t >>> Installing VSCode plugins ..."
source "$root_dir/etc/scripts/install-vscode-plugins.sh" --silent --plugins-list "etc/vscode.plugins.txt"


log_info "\t >>> Ignoring Focusrite Scarlett Solo automount"
echo "UUID=DC798778-543D-396B-A11F-2EC42F3500F9 none msdos ro,noauto" |
	sudo tee -a /etc/fstab >/dev/null


log_info "\t >>> Configuring Homebrew's environment"
if ! grep -q "$HOMEBREW_PREFIX/bin/bash" /etc/shells; then
	log_info "\t >>> Setting Homebrew's bash as the default shell"
	echo "$HOMEBREW_PREFIX/bin/bash" | sudo tee -a /etc/shells
	echo "$HOMEBREW_PREFIX/bin/fish" | sudo tee -a /etc/shells
	chsh -s "$HOMEBREW_PREFIX/bin/bash" "$(whoami)"
fi

if [ -f /etc/paths.d/homebrew ]; then
	# Don't want /etc/paths.d/homebrew making any changes to $PATH.
	# Homebrew's envvars will be explicitly set in .bash_profile and config.fish
	log_info "\t >>> Removing /etc/paths.d/homebrew ..."
	sudo rm /etc/paths.d/homebrew
fi


echo "ok" > "$bootstrap_finished"
log_success "\t >>> Finished!"
