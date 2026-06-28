# shellcheck disable=SC2034,SC2059,SC2155,SC2164

# ================= #
# ENVIRONMENT SETUP #
# ================= #

export HOSTNAME="$HOSTNAME"
export SHORT_HOSTNAME="${HOSTNAME/%.local/}"

export LC_CTYPE="UTF-8"
export LC_COLLATE="en_US.UTF-8"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export BUN_RUNTIME_TRANSPILER_CACHE_PATH="$XDG_CACHE_HOME/bun/cache-transpiler"
export CODE="$HOME/Developer"
export DENO_DIR="$XDG_CACHE_HOME/deno"
export DENO_INSTALL_ROOT="$DENO_DIR/bin"
export DENO_REPL_HISTORY="$DENO_DIR/repl_history.txt"
export DO_NOT_TRACK=1
export DOCUMENTS="$HOME/Documents"
export DOWNLOADS="$HOME/Downloads"
export EXTERNAL_VOLUME="#EXTERNAL_VOLUME"
export GRADLE_USER_HOME="$XDG_CACHE_HOME/gradle"
export ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/"
export LIMA_HOME="#LIMA_HOME"
export LF_BOOKMARKS_PATH="$XDG_CONFIG_HOME/lf/bookmarks"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export SHELL_SESSIONS_DISABLE=1
export VCPKG_ROOT="$HOME/Developer/github/vcpkg"
export VCPKG_DISABLE_METRICS=true
export VOLUMES="/Volumes"
export YARN_CACHE_FOLDER="$XDG_CACHE_HOME/yarn"

_arch="$(uname -m)"

if [ -z "$HOMEBREW_PREFIX" ]; then
	if [ "$_arch" = "arm64" ]; then
		type -ft /opt/homebrew/bin/brew &>/dev/null &&
			export HOMEBREW_PREFIX="/opt/homebrew"
	elif [ "$_arch" = "x86_64" ]; then
		type -ft /usr/local/bin/brew &>/dev/null &&
			export HOMEBREW_PREFIX="/usr/local"
	fi
fi

[ -n "$HOMEBREW_PREFIX" ] &&
	export SHELL="$HOMEBREW_PREFIX/bin/bash" &&
	export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar" &&
	export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"

[ -n "$HOMEBREW_PREFIX" ] &&
[[ ! ":$INFOPATH:" == *":$HOMEBREW_PREFIX/share/info:"* ]] && {
	if [ -z "$INFOPATH" ]
	then export INFOPATH="$HOMEBREW_PREFIX/share/info"
	else export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH}"
	fi
}

[[ ! ":$MANPATH:" == *":/usr/share/man:"* ]] && {
	if [ -z "$MANPATH" ]
	then export MANPATH="/usr/share/man"
	else export MANPATH="/usr/share/man:${MANPATH}"
	fi
}

[ -n "$HOMEBREW_PREFIX" ] &&
[[ ! ":$MANPATH:" == *":$HOMEBREW_PREFIX/share/man:"* ]] && {
	if [ -z "$MANPATH" ]
	then export MANPATH="$HOMEBREW_PREFIX/share/man"
	else export MANPATH="$HOMEBREW_PREFIX/share/man:${MANPATH}"
	fi
}

[ -n "$HOMEBREW_PREFIX" ] &&
[ -d "$HOMEBREW_PREFIX/opt/libpq/bin:$PATH" ] &&
[[ ! ":$PATH:" == *":$HOMEBREW_PREFIX/opt/libpq/bin:"* ]] &&
	export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"

[ -n "$HOMEBREW_PREFIX" ] &&
[[ ! ":$PATH:" == *":$HOMEBREW_PREFIX/sbin:"* ]] &&
	export PATH="$HOMEBREW_PREFIX/sbin:$PATH"

[ -n "$HOMEBREW_PREFIX" ] &&
[[ ! ":$PATH:" == *":$HOMEBREW_PREFIX/bin:"* ]] &&
	export PATH="$HOMEBREW_PREFIX/bin:$PATH"

[[ ! ":$PATH:" == *":$HOME/.docker/bin:"* ]] &&
	export PATH="$PATH:$HOME/.docker/bin"

[[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]] &&
	export PATH="$PATH:$HOME/.local/bin"

[[ ! ":$PATH:" == *":$XDG_CACHE_HOME/bun/bin:"* ]] &&
	export PATH="$PATH:$XDG_CACHE_HOME/bun/bin"

if [[ "$(type -ft python3)" == "file" ]]; then
	PYTHON3_BIN_PATH="$(python3 -c "import site; print(site.USER_BASE + '/bin')")"
	[[ ! ":$PATH:" == *":$PYTHON3_BIN_PATH:"* ]] &&
		export PATH="$PATH:$PYTHON3_BIN_PATH"
fi

# NOTES:
# - `PROMPT_COMMAND` needs to be set before running `mise activate bash`.
#   Otherwise it won't have any effect.
# - `history -a` will immediately add the previous command to Bash's history.
export PROMPT_COMMAND="history -a"
if [[ "$(type -ft mise)" == "file" ]]; then
	eval "$(mise activate bash)"
else
	export PROMPT_COMMAND="history -a"
fi
if [ "$_arch" = "arm64" ]; then
	export MISE_AMD64_CACHE_DIR="$XDG_CACHE_HOME/mise-amd64"
	export MISE_AMD64_CONFIG_DIR="$XDG_CONFIG_HOME/mise-amd64"
	export MISE_AMD64_STATE_DIR="$XDG_STATE_HOME/mise-amd64"
	export MISE_AMD64_DATA_DIR="$XDG_DATA_HOME/mise-amd64"
fi

# ============== #
# USER FUNCTIONS #
# ============== #

clear_quarantine () {
	if [ -z "$1" ]; then
		xattr -dr com.apple.quarantine "$HOME/Documents"
		xattr -dr com.apple.quarantine "$HOME/Downloads"
	else
		xattr -dr com.apple.quarantine "$1"
	fi
}

if [[ "$(type -ft gpg)" = "file" ]]; then
# Decrypt password-encrypted file.
gpg_dec_file () {
	local src="$1"
	local dst="$2"
	if [ -s "$src" ]; then
		[ -z "$dst" ] && gpg --decrypt "$src" 2>/dev/null
		[ -n "$dst" ] && gpg --decrypt "$src" > "$dst"
	fi
}

# Encrypt a file with a password.
gpg_enc_file () {
	local src="$1"
	local dst="$2"
	if [ -s "$src" ]; then
		[ -z "$dst" ] && gpg --symmetric "$src"
		[ -n "$dst" ] && gpg --symmetric "$src" "$dst"
	fi
}
fi

# Display for how long the computer has been turned on
howlong ()  {
	system_profiler SPSoftwareDataType -detailLevel mini |
		sed -nE 's/.*Time since boot: (.+)/\1/p'
}

# Handling mise for AMD64 under Apple Silicon
[ "$_arch" = "arm64" ] && [ -x ~/.local/bin/mise-amd64 ] &&
mise-amd64 () {
	local MISE_CACHE_DIR="$MISE_AMD64_CACHE_DIR"
	local MISE_CONFIG_DIR="$MISE_AMD64_CONFIG_DIR"
	local MISE_STATE_DIR="$MISE_AMD64_STATE_DIR"
	local MISE_DATA_DIR="$MISE_AMD64_DATA_DIR"
	export MISE_CACHE_DIR
	export MISE_CONFIG_DIR
	export MISE_STATE_DIR
	export MISE_DATA_DIR
	"$HOME/.local/bin/mise-amd64" "$@"
}

# Create a directory if it doesn't exist and cd into it.
mkcd () {
	if [ -n "$1" ]; then
		mkdir -p "$1" && cd "$1"
	else
		echo "Usage: mkcd <dir>"
	fi
}

reset_alttab_trial () {
	local appname="AltTab"
	local domain="com.lwouis.alt-tab-macos.license"
	local key="trialStartDate"
	local value="$(gdate +%s.%N)"

	echo "Killing $appname ..."
	killall "$appname"
	sleep 1

	echo "Resetting the trial's key ..."
	defaults write "$domain" "$key" -string "$value"
	sleep 1

	echo "Restarting $appname ..."
	open -a AltTab
}

# Taken from https://stackoverflow.com/a/44811468
# Sanite a string to produce a valid file name.
sanitize () {
	local s="$1"
	s="${s//[^[:alnum:]\.]/-}"
	s="${s//+(-)/-}"
	s="${s/#-}"
	s="${s/%-}"
	echo "$s"
	# ... or convert to lowercase
	# echo "${s,,}"
}

# Remove files in a secure manner using GNU shred.
secrm () {
	if [ $# -eq 0 ]; then
		echo "Usage: secrm <file>|<dir>"
		return 1
	fi

	for i in "$@"; do
		local item="$i"
		if [ -f "$item" ]; then
			[ "$SECRM_VERBOSE" = "1" ] && echo "shred $item"
			shred --iterations=3 --force --random-source=/dev/urandom \
				--remove=wipe --zero "$item" 1>/dev/null

		elif [ -h "$item" ]; then
			[ "$SECRM_VERBOSE" = "1" ] && echo "rm $item"
			rm "$item" >/dev/null

		elif [ -d "$item" ]; then
			chmod u+rwx "$item"
			local children=$(/bin/ls -1A "$item")
			if [ -n "$children" ]; then
				pushd "$item" >/dev/null
				# shellcheck disable=SC2086
				secrm $children
				local res=$?
				popd >/dev/null
				if [ $res -eq 0 ]; then
					[ "$SECRM_VERBOSE" = "1" ] && echo "rmdir $item/"
					rmdir "$item"
				fi
			fi
		fi
	done
}

# ============================= #
# INTERACTIVE ENVIRONMENT SETUP #
# ============================= #
[[ ! $- == *i* ]] && return 0

export BAT_THEME="tokyonight-moon"
export CDPATH="."
export CLICOLOR=1
export EDITOR="nvim"
export FZF_DEFAULT_COMMAND="fd --hidden --threads 2 --type f"
export FZF_DEFAULT_OPTS="--ansi --border=rounded --cycle --height=100% "
export FZF_DEFAULT_OPTS+="--layout=reverse --tabstop=4 --tiebreak=chunk,length,begin"
export FZF_ALT_C_COMMAND="fd --hidden --threads 2 --type d"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export GPG_TTY=$(tty)
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignorespace:erasedups
export HISTIGNORE="?:??:set [+-]o *"
export HISTTIMEFORMAT="%F %T "
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export LESSCHARSET="UTF-8"
export MANPAGER="env ACT_AS_PAGER=yes SKIP_LOADING_PLUGINS=yes nvim -n +Man!"
export NVIMPAGER="env ACT_AS_PAGER=yes SKIP_LOADING_PLUGINS=yes nvim -n -R -i NONE"
export PROMPT_DIRTRIM=2

# 256-color table reference
# https://github.com/ThomasDickey/old-xterm/blob/master/vttests/256colors2.pl
color_reset='\001\x1b[0m\002'
color_fg_dark_black='\001\x1b[38;5;0m\002'
color_fg_dark_red='\001\x1b[38;5;1m\002'
color_fg_dark_green='\001\x1b[38;5;2m\002'
color_fg_dark_yellow='\001\x1b[38;5;3m\002'
color_fg_dark_blue='\001\x1b[38;5;4m\002'
color_fg_dark_purple='\001\x1b[38;5;5m\002'
color_fg_dark_cyan='\001\x1b[38;5;6m\002'
color_fg_dark_white='\001\x1b[38;5;7m\002'

color_fg_light_black='\001\x1b[38;5;8m\002'
color_fg_light_red='\001\x1b[38;5;9m\002'
color_fg_light_green='\001\x1b[38;5;10m\002'
color_fg_light_yellow='\001\x1b[38;5;11m\002'
color_fg_light_blue='\001\x1b[38;5;12m\002'
color_fg_light_purple='\001\x1b[38;5;14m\002'
color_fg_light_cyan='\001\x1b[38;5;14m\002'
color_fg_light_white='\001\x1b[38;5;15m\002'

color_bg_dark_black='\001\x1b[48;5;0m\002'
color_bg_dark_red='\001\x1b[48;5;1m\002'
color_bg_dark_green='\001\x1b[48;5;2m\002'
color_bg_dark_yellow='\001\x1b[48;5;3m\002'
color_bg_dark_blue='\001\x1b[48;5;4m\002'
color_bg_dark_purple='\001\x1b[48;5;5m\002'
color_bg_dark_cyan='\001\x1b[48;5;6m\002'
color_bg_dark_white='\001\x1b[48;5;7m\002'

color_bg_light_black='\001\x1b[48;5;8m\002'
color_bg_light_red='\001\x1b[48;5;9m\002'
color_bg_light_green='\001\x1b[48;5;10m\002'
color_bg_light_yellow='\001\x1b[48;5;11m\002'
color_bg_light_blue='\001\x1b[48;5;12m\002'
color_bg_light_purple='\001\x1b[48;5;14m\002'
color_bg_light_cyan='\001\x1b[48;5;14m\002'
color_bg_light_white='\001\x1b[48;5;15m\002'

ps1_git() {
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		local git_status="$(git status --porcelain --short)"
		if [ $! ]; then
			local git_status_dirty="$([ "$(echo "$git_status" | grep -c .)" -gt 0 ] && echo "*")"
			local git_branch_name="$(git branch --show-current)"
			if [ -z "$git_branch_name" ]; then
				git_branch_name="#$(git describe --tags HEAD)"
			fi
			printf "${color_fg_dark_red}$git_branch_name$git_status_dirty${color_reset} "
		fi
	fi
}
ps1_date() {
	printf "${color_bg_dark_green}${color_fg_dark_black} $(date '+%a %T') ${color_reset}"
}
ps1_lflevel() {
	if [ -n "$LF_LEVEL" ]; then
		printf "${color_bg_dark_green}${color_fg_dark_black} $LF_LEVEL ${color_reset}"
	fi
}
ps1_shlevel() {
	if [ "$SHLVL" -gt "1" ]; then
		printf "${color_bg_dark_white}${color_fg_dark_black} $((SHLVL - 1)) ${color_reset}"
	fi
}
export PS1='$(ps1_date)$(ps1_shlevel) $(printf $color_fg_dark_green)\W$(printf $color_reset) $(ps1_git)'

bash_completion="$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
# shellcheck disable=SC1090
[ -r "$bash_completion" ] &&
	source "$bash_completion" >/dev/null
unset bash_completion

cli_tools="/Library/Developer/CommandLineTools"
git_completion="$cli_tools/usr/share/git-core/git-completion.bash"
# shellcheck disable=SC1090
[ -r "$git_completion" ] &&
	source "$git_completion"
unset cli_tools
unset git_completion

! type -t fzf-file-widget &>/dev/null &&
type -ft fzf &>/dev/null &&
	eval "$(fzf --bash)"

clear_screen_and_scrollback_buffer() {
	clear
	printf "\e[3J"
}

code () {
	local _code="$HOMEBREW_PREFIX/bin/code"
	$_code \
		--user-data-dir "$XDG_CACHE_HOME/code/data" \
		--extensions-dir "$XDG_CACHE_HOME/code/extensions" \
		"$@" &>/dev/null
}

# Start lf in the current directory or in the given one.
e () {
	lf "$1"
	if [ -f "$TMPDIR/lfcd" ]; then
		local dir=$(cat "$TMPDIR/lfcd")
		[ -d "$dir" ] && cd "$dir"
		rm -rf "$TMPDIR/lfcd"
	fi
}

# Pager-like implementation using neovim
# shellcheck disable=SC2120
pager () {
	[ -n "$1" ] && [ ! -f "$1" ] && return 0

	local file=$([ -n "$1" ] && echo "$1" || echo "-")
	nvim -n -u NONE -i NONE -R \
		-c "map q :q<CR>" \
		-c "set laststatus=0" \
		-c "set number" \
		-c "hi Normal ctermbg=NONE guibg=NONE" \
		-c "syntax on" "$file"
}

# Purge temporary data from some programs.
complete -W "all bash cache clipboard nvim safari zsh" purge
purge () {
	for item in "$@"; do
		if [ "$item" == "all" ]; then
			echo "Purging all items, except for the cache ..."
			purge bash clipboard nvim safari zsh

		elif [ "$item" == "bash" ]; then
			echo "Purging Bash ..."
			history -c
			[ -f "$HOME/.bash_history" ] && secrm "$HOME/.bash_history"

		elif [ "$item" == "cache" ]; then
			echo "Purging the cache ..."
			sudo /usr/sbin/purge

		elif [ "$item" == "clipboard" ]; then
			echo "Purging the clipboard ..."
			pbcopy < /dev/null

		elif [ "$item" == "nvim" ]; then
			echo "Purging Neovim ..."
			for file in "$XDG_DATA_HOME"/nvim/shada/*.shada; do
				rm -f "$file"
			done
			for file in "$XDG_STATE_HOME"/nvim/shada/*.shada; do
				rm -f "$file"
			done
			[ -d "$XDG_STATE_HOME/nvim/undo" ] &&
			[ -n "$(lsa "$XDG_STATE_HOME"/nvim/undo/)" ] &&
				rm -rf "$XDG_STATE_HOME"/nvim/undo/*

		elif [ "$item" = "safari" ]; then
			echo "Purging Safari ..."
			rm -rf ~/Library/Safari/Favicon\ Cache

		elif [ "$item" == "zsh" ]; then
			echo "Purging Zsh ..."
			rm -rf ~/.zsh_history
			rm -rf ~/.zsh_sessions
		fi
	done
}

test_underline_styles () {
	echo -e "\x1b[4:0m4:0 none\x1b[0m \x1b[4:1m4:1 straight\x1b[0m " \
		"\x1b[4:2m4:2 double\x1b[0m \x1b[4:3m4:3 curly" \
		"\x1b[0m \x1b[4:4m4:4 dotted\x1b[0m \x1b[4:5m4:5 dashed\x1b[0m"
}

test_underline_colors () {
	echo -e "\x1b[4;58:5:203mred underline (256)" \
		"\x1b[0m \x1b[4;58:2:0:255:0:0mred underline (true color)\x1b[0m"
}

vi_mode_edit_wo_executing () {
	local tmp_file="$(mktemp)"
	printf '%s\n' "$READLINE_LINE" > "$tmp_file"
	"$EDITOR" "$tmp_file"
	READLINE_LINE="$(cat "$tmp_file")"
	READLINE_POINT="${#READLINE_LINE}"
	rm -f "$tmp_file"
}

alias -- -="cd -"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias beep="tput bel"
alias brewi="brew info"
alias brewo="brew outdated"
alias brewog="brew outdated --greedy"
alias brews="brew search"
alias brewu="brew update --verbose"
alias compose="docker-compose"
alias gita="git add"
alias gitaa="git add --all"
alias gitaac="git add --all && git commit -v"
alias gitau="git add -u"
alias gitauc="git add -u && git commit -v"
alias gitb="git branch"
alias gitba="git branch --all"
alias gitc="git commit -v"
alias gitcfddx="git clean -fddx"
alias gitco="git checkout"
alias gitd="git diff"
alias gitdc="git diff --diff-filter=U --relative"
alias gitdcs="git diff --diff-filter=U --name-only --relative"
alias gitds="git diff --staged"
alias gitf="git fetch"
alias gitfa="git fetch --all"
alias gitfap="git fetch --all --prune"
alias gitfp="git fetch --prune"
alias gitl="git log"
alias gitlo="git log --oneline"
alias gitm="git merge"
alias gitma="git merge --abort"
alias gitp="git pull"
alias gitpb="git pull origin \$(git rev-parse --abbrev-ref HEAD)"
alias gitpd="git push --delete"
alias gitpr="git pull --rebase"
alias gits="git status"
alias gitsh="git show"
alias gitshno="git show --name-only"
alias gitss="git status -s"
alias gitst="git stash"
alias gitstp="git stash pop"
alias gittd="git tag --delete"
alias gituidx-noskip="git update-index --no-skip-worktree"
alias gituidx-skip="git update-index --skip-worktree"
alias gitwa="git worktree add"
alias gitwl="git worktree list"
alias gitwr="git worktree remove"
alias l="eza -1"
alias la="eza -1a"
alias lar="eza -1aR"
# shellcheck disable=SC2139
alias less="pager"
alias lh="eza -1ad .??*"
alias ll="eza -lhS --icons"
alias lla="eza -ahlS --icons"
alias llar="eza -ahlRS --icons"
alias llat="eza -ahlS --icons --total-size"
alias llh="eza -adhlS --icons .??*"
alias llr="eza -lhRS --icons"
alias llt="eza -lhS --icons --total-size"
alias lr="eza -1R"
alias ls="eza"
alias lsa="eza -ah"
alias n="nvim"
alias nn="nvim -n -u NONE -i NONE"
alias npma="npm audit"
alias npmci="npm ci"
alias npmcip="npm ci --production"
alias npmi="npm install"
alias npmo="npm outdated"
alias npmog="npm outdated -g"
alias npmr="npm run"
alias npmrb="npm run build"
alias npmrd="npm run dev"
alias npmrs="npm run start"
alias npms="npm search"
alias q="exit 0"
alias tar="COPYFILE_DISABLE=1 /usr/bin/tar"
alias wcc="wc -c"
alias wcl="wc -l"
alias whicha="which -a"
alias z="zed"

shopt -s checkwinsize
bind Space:magic-space
shopt -s globstar 2>/dev/null
shopt -s nocaseglob
shopt -s histappend
shopt -s cmdhist
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind -m vi -x '"v": " vi_mode_edit_wo_executing"'
# shellcheck disable=SC2016
bind -m vi-insert '"\C-e": " `__fzf_cd__`\n"'
bind -m vi-insert '"\C-k": "\C-u clear_screen_and_scrollback_buffer\n"'
bind -m vi-insert '"\C-l": "\C-u clear\n"'
bind -m vi-insert '"\C-p": history-search-backward'
bind -m vi-insert '"\C-n": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'
shopt -s autocd 2>/dev/null
shopt -s direxpand 2>/dev/null
shopt -s dirspell 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s cdable_vars
