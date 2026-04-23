# ================= #
# ENVIRONMENT SETUP #
# ================= #

set --export HOSTNAME "$hostname"
set --export SHORT_HOSTNAME (string match --groups-only --regex "(.*)\.local" "$hostname")

set --export XDG_CACHE_HOME "$HOME/.cache"
set --export XDG_CONFIG_HOME "$HOME/.config"
set --export XDG_DATA_HOME "$HOME/.local/share"
set --export XDG_STATE_HOME "$HOME/.local/state"

set --export BUN_RUNTIME_TRANSPILER_CACHE_PATH "$XDG_CACHE_HOME/bun/cache-transpiler"
set --export CODE "$HOME/Developer"
set --export DO_NOT_TRACK 1
set --export DOCUMENTS "$HOME/Documents"
set --export DOWNLOADS "$HOME/Downloads"
set --export EXTERNAL_VOLUME "#EXTERNAL_VOLUME"
set --export GRADLE_USER_HOME "$XDG_CACHE_HOME/gradle"
set --export ICLOUD "$HOME/Library/Mobile Documents/com~apple~CloudDocs/"
set --export LIMA_HOME "#LIMA_HOME"
set --export LF_BOOKMARKS_PATH "$XDG_CONFIG_HOME/lf/bookmarks"
set --export NPM_CONFIG_CACHE "$XDG_CACHE_HOME/npm"
set --export VCPKG_ROOT "$HOME/Developer/github/vcpkg"
set --export VCPKG_DISABLE_METRICS true
set --export VOLUMES "/Volumes"
set --export YARN_CACHE_FOLDER "$XDG_CACHE_HOME/yarn"

set --local _arch (uname -m)

if [ -z "$HOMEBREW_PREFIX" ]
	if [ "$_arch" = "arm64" ]
		type -fq /opt/homebrew/bin/brew &&
			set --export HOMEBREW_PREFIX "/opt/homebrew"
	else if [ "$_arch" = "x86_64" ]
		type -fq /usr/local/bin/brew &&
			set --export HOMEBREW_PREFIX "/usr/local"
	end
end

[ -n "$HOMEBREW_PREFIX" ] &&
	set --export SHELL "$HOMEBREW_PREFIX/bin/fish" &&
	set --export HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar" &&
	set --export HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"

[ -n "$HOMEBREW_PREFIX" ] &&
! string match -q "*$HOMEBREW_PREFIX/share/info:*" "$INFOPATH"  &&
begin
	[ -z "$INFOPATH" ] &&
		set --export INFOPATH "$HOMEBREW_PREFIX/share/info" ||
		set --export INFOPATH "$HOMEBREW_PREFIX/share/info:$INFOPATH"
end

! string match -q "*/usr/share/man:*" "$MANPATH"  &&
begin
	[ -z "$MANPATH" ] &&
		set --export MANPATH "/usr/share/man" ||
		set --export MANPATH "/usr/share/man:$MANPATH"
end

[ -n "$HOMEBREW_PREFIX" ] &&
! string match -q "*$HOMEBREW_PREFIX/share/man:*" "$MANPATH"  &&
begin
	[ -z "$MANPATH" ] &&
		set --export MANPATH "$HOMEBREW_PREFIX/share/man" ||
		set --export MANPATH "$HOMEBREW_PREFIX/share/man:$MANPATH"
end

fish_add_path --path "$HOMEBREW_PREFIX/opt/libpq/bin"
fish_add_path --path "$HOMEBREW_PREFIX/sbin"
fish_add_path --path "$HOMEBREW_PREFIX/bin"
fish_add_path --path --append "$HOME/.docker/bin"
fish_add_path --path --append "$HOME/.local/bin"
fish_add_path --path --append "$XDG_CACHE_HOME/bun/bin"

if type -fq mise &&
	mise activate fish | source
end
if [ "$_arch" = "arm64" ]
	set --export MISE_AMD64_CACHE_DIR "$XDG_CACHE_HOME/mise-amd64"
	set --export MISE_AMD64_CONFIG_DIR "$XDG_CONFIG_HOME/mise-amd64"
	set --export MISE_AMD64_STATE_DIR "$XDG_STATE_HOME/mise-amd64"
	set --export MISE_AMD64_DATA_DIR "$XDG_DATA_HOME/mise-amd64"
end

type -fq python3 &&
begin
	set --local PYTHON3_BIN_PATH (python3 -c "import site; print(site.USER_BASE + '/bin')")
	fish_add_path --path --append "$PYTHON3_BIN_PATH"
end

# ============== #
# USER FUNCTIONS #
# ============== #

if type -q gpg
function gpg_dec_file --description "Decrypt password-encrypted file."
	set --local src "$argv[1]"
	set --local dst "$argv[2]"
	if [ -s "$src" ]
		[ -z "$dst" ] && gpg --decrypt "$src" 2>/dev/null
		[ -n "$dst" ] && gpg --decrypt "$src" > "$dst"
	end
end
function gpg_enc_file --description "Encrypt a file with a password."
	set --local src "$argv[1]"
	set --local dst "$argv[2]"
	if [ -s "$src" ]
		[ -z "$dst" ] && gpg --symmetric "$src"
		[ -n "$dst" ] && gpg --symmetric "$src" "$dst"
	end
end
end

function howlong --description "Display for how long the computer has been turned on"
	string match --regex --groups-only '.*Time since boot: (.+)' \
		(system_profiler SPSoftwareDataType -detailLevel mini)
end

# Handling mise for AMD64 under Apple Silicon
if test "$_arch" = "arm64" && test -x ~/.local/bin/mise-amd64
function mise-amd64
	set --local --export MISE_CACHE_DIR "$MISE_AMD64_CACHE_DIR"
	set --local --export MISE_CONFIG_DIR "$MISE_AMD64_CONFIG_DIR"
	set --local --export MISE_STATE_DIR "$MISE_AMD64_STATE_DIR"
	set --local --export MISE_DATA_DIR "$MISE_AMD64_DATA_DIR"
	~/.local/bin/mise-amd64 $argv
end
end

function mkcd --description "Create a directory if it doesn't exist and cd into it."
	if [ -n "$argv[1]" ]
		mkdir -p "$argv[1]" && cd "$argv[1]"
	else
		echo "Usage: mkcd <dir>"
	end
end

function secrm --description "Remove files in a secure manner using GNU shred."
	bash --login -c "secrm $argv"
end

# Adapted from https://stackoverflow.com/a/44811468
# Sanite a string to produce a valid file name
function sanitize --description ""
	set --local s $argv[1]
	set --local s (echo "$s" | sed 's/[^[:alnum:]]\./-/g')
	set --local s (echo "$s" | sed -E 's/-+/-/g')
	set --local s (string trim --char=- -- "$s")
	echo "$s"
end

# ============================= #
# INTERACTIVE ENVIRONMENT SETUP #
# ============================= #
! status --is-interactive && return 0

! set -q MISE_FISH_AUTO_ACTIVATE &&
	set --universal MISE_FISH_AUTO_ACTIVATE "0"

set --export BAT_THEME "tokyonight-moon"
set --export EDITOR "nvim"
set --export FZF_DEFAULT_COMMAND "fd --hidden --threads 2 --type f"
set --export FZF_DEFAULT_OPTS "--ansi --border=rounded --cycle " \
	"--height=100% --layout=reverse --tabstop=4 --tiebreak=chunk,length,begin"
set --export FZF_ALT_C_COMMAND "fd --hidden --threads 2 --type d"
set --export FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set --export GPG_TTY (tty)
set --export HOMEBREW_NO_ANALYTICS 1
set --export HOMEBREW_NO_AUTO_UPDATE 1
set --export HOMEBREW_NO_INSTALL_CLEANUP 1
set --export LESSCHARSET UTF-8
set --export MANPAGER "env ACT_AS_PAGER=yes SKIP_LOADING_PLUGINS=yes nvim -n +Man!"
set --export NVIMPAGER "env ACT_AS_PAGER=yes SKIP_LOADING_PLUGINS=yes nvim -n -R -i NONE"

set fish_greeting
set __fish_git_prompt_hide_untrackedfiles 1
set __fish_git_prompt_showupstream "informative"
set __fish_git_prompt_char_upstream_ahead "↑"
set __fish_git_prompt_char_upstream_behind "↓"
set __fish_git_prompt_char_upstream_prefix ""
set __fish_git_prompt_char_cleanstate "#"
set __fish_git_prompt_char_conflictedstate "!"
set __fish_git_prompt_char_dirtystate "~"
set __fish_git_prompt_char_stagedstate "+"
set __fish_git_prompt_char_untrackedfiles "?"
set __fish_git_prompt_color_branch magenta
set __fish_git_prompt_color_dirtystate blue
set __fish_git_prompt_color_stagedstate yellow
set __fish_git_prompt_color_invalidstate red
set __fish_git_prompt_color_untrackedfiles $fish_color_normal
set __fish_git_prompt_color_cleanstate green
set __fish_git_prompt_show_informative_status 1
set fish_handle_reflow 1
set fish_color_command blue --bold
set fish_color_error red --bold
set fish_cursor_default block
set fish_cursor_insert block blink
set fish_cursor_replace_one underscore
set fish_cursor_visual block
set fish_escape_delay_ms 30

function fish_mode_prompt;
end

function prompt_cwd
	set_color black --background green
	echo -n " $(echo (prompt_pwd | string split /)[-1]) "
	set_color $fish_color_normal
end

function prompt_sh_level
	if [ "$SHLVL" -gt "1" ]
		set_color black --background white
		echo -n " $(math $SHLVL - 1) "
		set_color $fish_color_normal
		# echo -n " "
	end
end

function prompt_vi_mode
	if [ "$fish_bind_mode" = "default" ]
		set_color --background red
		set_color black
		echo -n " C "
		set_color normal
		# [ $SHLVL -eq 1 ] && echo -n " "
	else if [ "$fish_bind_mode" = "visual" ]
		set_color --background yellow
		set_color black
		echo -n " V "
		set_color normal
		# [ $SHLVL -eq 1 ] && echo -n " "
	end
end

function fish_prompt
	echo -n "$(prompt_cwd)$(prompt_vi_mode)$(prompt_sh_level) "
end

function fish_right_prompt
	echo -n "$(__fish_git_prompt) $(date '+%a %T')"
end

function fish_should_add_to_history
	set --local cmd (string split --no-empty ' ' $argv)
	if [ (string length $cmd[1]) -eq 1 ]
		return 1
	else if type -q $cmd[1]
		return 0
	else
		return 1
	end
end

function fish_title
	echo (prompt_pwd --dir-length=3 --full-length-dirs=1)
end

! type -q fzf-cd-widget &&
type -fq fzf &>/dev/null &&
	fzf --fish | source

function brew --description "Homebrew hook to handle specific commands"
	set --local homebrew (type -fp brew)
	if [ $argv[1] = "install" ] || [ $argv[1] = "upgrade" ]
		echo "Homebrew's install and upgrade commands should be executed in Bash (Apple Terminal)."
		echo "To force-execute them in Fish start the command with: $homebrew"
	else
		$homebrew $argv
	end
end

function clear_screen_and_scrollback_buffer --description "Clear the screen and purge the scrollback buffer."
	clear
	printf '\e[3J'
end

function code --description "Start VSCode with some default parameters"
	set --local _code "$HOMEBREW_PREFIX/bin/code"
	$_code \
		--user-data-dir "$XDG_CACHE_HOME/code/data" \
		--extensions-dir "$XDG_CACHE_HOME/code/extensions" \
		$argv &>/dev/null
end

function e --description "Start lf in the current directory or in the given one."
	lf "$argv[1]"
	if [ -f "$TMPDIR/lfcd" ]
		set --local dir (cat "$TMPDIR/lfcd")
		[ -d "$dir" ] && cd "$dir"
		rm -rf "$TMPDIR/lfcd"
	end
end

function pager --description "Pager-like implementation using neovim"
	set --function target "-"
	if [ -n "$argv[1]" ]
		set --function target "$argv[1]"
	end

	nvim -n -u NONE -i NONE -R \
		-c "map q :q<CR>" \
		-c "set laststatus=0" \
		-c "set number" \
		-c "hi Normal ctermbg=NONE guibg=NONE" \
		-c "syntax on" "$target"
end

complete --command purge \
	--argument "all bash cache clipboard fish nvim safari zsh" \
	--exclusive
function purge --description "Purge temporary data from some programs."
	for item in $argv
		if [ "$item" = "all" ]
			echo "Purging all items, except for the cache ..."
			purge bash clipboard fish nvim safari zsh

		else if [ "$item" = "bash" ]
			bash -i -c "purge bash"

		else if [ "$item" = "cache" ]
			echo "Purging the cache ..."
			sudo /usr/sbin/purge

		else if [ "$item" = "clipboard" ]
			echo "Purging the clipboard ..."
			pbcopy < /dev/null

		else if [ "$item" = "fish" ]
			echo "Purging Fish ..."
			echo 'yes' | history clear &>/dev/null

		else if [ "$item" = "nvim" ]
			echo "Purging Neovim ..."
			for file in "$XDG_DATA_HOME"/nvim/shada/*.shada
				rm -f "$file"
			end
			for file in "$XDG_STATE_HOME"/nvim/shada/*.shada
				rm -f "$file"
			end
			[ -d "$XDG_STATE_HOME"/nvim/undo/ ] &&
			[ -n "$(lsa "$XDG_STATE_HOME"/nvim/undo/)" ] &&
				rm -rf "$XDG_STATE_HOME"/nvim/undo/*

		else if [ "$item" = "safari" ]
			echo "Purging Safari ..."
			rm -rf ~/Library/Safari/Favicon\ Cache

		else if [ "$item" = "zsh" ]
			echo "Purging Zsh ..."
			rm -rf ~/.zsh_history
			rm -rf ~/.zsh_sessions
		end
	end
end

function test_underline_styles --description "Prints underline text in several styles."
	echo -e "\x1b[4:0m4:0 none\x1b[0m \x1b[4:1m4:1 straight\x1b[0m " \
		"\x1b[4:2m4:2 double\x1b[0m \x1b[4:3m4:3 curly" \
		"\x1b[0m \x1b[4:4m4:4 dotted\x1b[0m \x1b[4:5m4:5 dashed\x1b[0m"
end

function test_underline_colors --description "Prints text with colored underlines"
	echo -e "\x1b[4;58:5:203mred underline (256)" \
		"\x1b[0m \x1b[4;58:2:0:255:0:0mred underline (true color)\x1b[0m"
end

abbr -a -- - 'cd -'
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

fish_vi_key_bindings
bind --mode default \cf accept-autosuggestion
bind --mode insert \cf accept-autosuggestion
bind --mode visual \cf accept-autosuggestion
bind --mode default \cy accept-autosuggestion execute
bind --mode insert \cy accept-autosuggestion execute
bind --mode visual \cy accept-autosuggestion execute
bind --mode default ctrl-k 'clear_screen_and_scrollback_buffer; commandline -f repaint'
bind --mode insert ctrl-k 'clear_screen_and_scrollback_buffer; commandline -f repaint'
bind --mode visual ctrl-k 'clear_screen_and_scrollback_buffer; commandline -f repaint'
bind --mode default ctrl-l 'clear; commandline -f repaint'
bind --mode insert ctrl-l 'clear; commandline -f repaint'
bind --mode visual ctrl-l 'clear; commandline -f repaint'

if type -q fzf-cd-widget
	bind --mode default \ce fzf-cd-widget
	bind --mode insert \ce fzf-cd-widget
	bind --mode visual \ce fzf-cd-widget
end
