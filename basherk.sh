# basherk
# Replacement of .bashrc

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# basherk specific
basherk_ver=124
basherk_date="25 February 2017"
basherk_src=${BASH_SOURCE[0]}
basherk_dir=$(dirname "$basherk_src")

# colours, credit: http://stevelosh.com/blog/2009/03/candy-colored-terminal/
D=$'\e[37;49m'
BLUE=$'\e[34;49m'
CYAN=$'\e[36;49m'
GREEN=$'\e[32;49m'
ORANGE=$'\e[33;49m'
PINK=$'\e[35;49m'
RED=$'\e[31;49m'

[[ $1 == "-v" ]] && echo "basherk $basherk_ver ($basherk_date)" && return
[[ $1 == "--version" ]] && echo "basherk $basherk_ver ($basherk_date)" && return

# source pre-basherk dependencies
[[ -f "$basherk_dir/basherk-custom.sh" ]] && . "$basherk_dir/pre-basherk.sh"

# source custom basherk user definitions
[[ -f "$basherk_dir/basherk-custom.sh" ]] && . "$basherk_dir/basherk-custom.sh"

alias basherk='. "$basherk_src"'

export GREP_OPTIONS='--color=auto'

# history options
export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # 100k lines of history
export HISTFILESIZE=100000              # 100kb max history size
export HISTIGNORE=clear:countsize:df:f:find:gd:gds:staged:gdsw:gdw:gl:gla:gs:stashes:graph:graphall:h:"h *":history:la:ls:mc:"open .":ps:pwd:ubash:ubashall:"* --version":test:"time *":suho
shopt -s histappend                     # append to history, don't overwrite
shopt -s cdspell                        # autocorrect for cd

# Source git completion
if [ -f ~/.git-completion.bash ]; then
        . ~/.git-completion.bash
fi

os="$(uname)"
host="$(hostname)"

[[ $os == "Darwin" ]] && os="macOS"
[[ $host =~ ^(Zen|Obsidian)$ ]] && os="Windows"

# Functions that require defining first
[[ $os == "macOS" ]] && alias la='ls -aGhl'
[[ $os =~ ^(Linux|Windows)$ ]] && alias la='ls -ahGl --color=auto'

[[ $os =~ ^(macOS|Windows)$ ]] && {
    alias gitale='cd ~/.dev/repos/ale && gitwelcome'
    alias gitpd='cd ~/.dev/repos/phonedirectory && gitwelcome'
    alias gitr='cd ~/.dev/repos'
}

[[ $os =~ ^(Linux|Windows)$ ]] && {
    alias vwmod='stat --format "%a"'
    alias linver='cat /etc/*-release'
}

# Single OS aliases
case $os in
    macOS)
        alias ls='ls -G'
        alias tailf='tail -f'

        alias el='now && tail -f /usr/local/var/log/apache2/error_log'
        alias elm='now && tail -f /var/log/mysql.log'
        alias elmnd='now && tail -f /usr/local/var/log/mysqlnd.log'

        alias fcache='sudo dscacheutil -flushcache'
        alias suho='sudo sublime /etc/hosts'

        alias vwmod='stat -f "%OLp"' # chmod supplement

        # When Time Mahine is backing up extremely slowly, it's usually due to throttling
        alias tmnothrottle='sudo sysctl debug.lowpri_throttle_enabled=0'
        alias tmthrottle='sudo sysctl debug.lowpri_throttle_enabled=1'
        ;;
    Linux)
        alias cdnet='cd /etc/sysconfig/network-scripts/'
        alias el='now && tailf /var/log/httpd/error_log'
        ;;
    Windows)
        # ~/.dev is symlinked to /mnt/c/Dropbox/Web Development
        function yum() {
            if [[ $1 == "search" ]]; then apt-cache "$@"
            elif [[ $1 == "provides" ]]; then apt-file ${@/provides/search}
            elif [[ $1 == "info" ]]; then apt-cache ${@/info/show}
            elif [[ "$1 $2" == "list installed" ]]; then apt ${@/installed/--installed}
            else apt-get "$@"
            fi
        }

        alias elp='tail -f /c/xMAMP/logs/phperror.log'
        alias suho='vi /mnt/c/Windows/System32/drivers/etc/hosts'
        ;;
esac

alias gitwd='cd /var/www/html && gs'
alias gitwelcome='graphall -10 && tcommits && gs'

# Redefine builtin commands
alias cp='cp -iv' # interactive and verbose
alias mv='mv -iv'
alias rm='rm -iv'
alias df='df -h' # human readable
alias mkdir='mkdir -pv' # Make parent directories as needed and be verbose

# General aliases
alias back='cd "$OLDPWD"'
alias countsize='du -sch'
alias fuck='sudo $(history -p \!\!)' # Redo last command as sudo
alias now='date +"%c"'
alias pwf='printf '%s' "${PWD##*/}"'
alias vollist='echo && echo pvs && pvs && echo && echo vgs && vgs && echo && echo lvs && lvs'
alias voldisp='echo && echo pvdisplay && pvdisplay && echo && echo vgdisplay && vgdisplay && echo && echo lvdisplay && lvdisplay'

# Custom commands
alias travmysql='mysql -u trav -p'
alias mysql_shutdown='mysqladmin -u trav -p shutdown'
alias elmd='now && tailf /var/log/mysqld.log'
alias ipas='ip addr show | hlp "inet .*/"'

# Git aliases
alias gb='git branch -a'
alias gd='git diff'
alias gdom='git diff origin/master'
alias gds='staged'
alias gdw='git diff --color-words'
alias gdsw='git diff --staged --color-words'
alias gl='graph'
alias gla='graphall'
alias gnb='git checkout -b'
alias gs='git status'
alias stashes='git stash list'
alias gsl='stashes'
alias gitsquashlast='git rebase -i HEAD~2'
alias graph="git log --graph -14 --format=format:'%Cgreen%h%Creset - %<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d'"
alias graphall="git log --graph -20 --format=format:'%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d' --branches --remotes --tags"
alias stage='git add -p'
alias staged='git diff --staged'
alias unstage='git reset -q HEAD --'
alias discard='git checkout --'
alias discardpatch='git checkout -p'
alias nevermind='echo "You will have to ${RED}git reset --hard HEAD && git clean -d -f${D} but it removes untracked things like vendor"'

# Instructions / remider aliases
alias gitdeleteremotebranch='echo "to delete remote branch, ${PINK}git push origin :<branchName>"'
alias gitprune='echo "git remote prune origin" will automatically prune all branches that no longer exist'
alias gitrebase='echo "usage: git checkout ${GREEN}develop${D}" &&
                 echo "       git rebase ${PINK}master${D}" &&
                 echo &&
                 echo "Rebase ${GREEN}branch${D} onto ${PINK}base${D}, which can be any kind of commit reference:" &&
                 echo "an ID, branch name, tag or relative reference to HEAD."'
alias gitundocommit='echo "git reset --soft HEAD^"'
alias tcommits='echo "Total commits for ${GREEN}$(git_repo_name): ${PINK}$(git log --oneline --all | wc -l)"${D}'

# Count characters in a string
function cchar() {
    local OPTIND

    while getopts "a:" opt; do
        case $opt in
            a)
                echo ${#OPTARG}
                return
                ;;
        esac
    done

    echo "string is ${RED}${#1}${D} characters long"
}

function cd() {
    command cd "$1" && pwd && la
}

# commit
# wrapper for git commit
# counts characters, checks spelling and asks to commit
function commit() {
    local message="$1"
    local len=$(cchar -a "$message")

    [[ $len > 50 ]] && {
        echo "${RED}$len characters long${D}"
        echo "truncated to 50: '${BLUE}${message:0:50}${D}'"
        return
    } || echo "${GREEN}$len characters long${D}"

    echo
    echo "${BLUE}Spell check:${D}"
    echo "$message" | aspell -a

    echo "git commit -m ${PINK}\"$message\"${D}"
    read -p "Commit using this message? [y/N] " commit

    [[ "$commit" == "y" ]] && {
        git commit -m "$message"
    } || echo "Aborted"
}

# Compare 2 strings
function compare() {
    [[ -z "$1" ]] && exit

    [[ "$1" == "$2" ]] && echo "${GREEN}2 strings match${D}" ||
    echo "${RED}Strings don't match${D}"
}

function exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fix shitty find command
function f() {
    local location=$1
    local search=$2
    local sudo=$3
    local args
    local hl=${search/\*/}
    hl=${hl/./\\.}

    [[ -z $1 ]] && {
        echo "search for files, commits or file contents"
        echo "usage: f location search [sudo]"
        echo
        echo "locations:"
        echo "    folders ( / . /usr )"
        echo "    path (will systematically search each folder in \$PATH)"
        echo "    in (search file contents)"
        echo "    commits (uses git grep to search through all committed code)"
    } || {
        if [[ $location == "path" ]]; then $sudo find ${PATH//:/ } -maxdepth 1 -name "$search" -print | hlp "$hl"
        elif [[ $location == "in" ]]; then {
            if [[ "$3" != "--old" ]]; then {
                args="$@"
                args=${args:3}
                if exists rg; then
                    rg $args
                elif exists ag; then
                    ag $args
                else searchcontents $args
                fi
            } else {
                searchcontents "$2" $4 $5
            } fi
        }
        elif [[ $location == "commits" ]]; then git grep "$search" $(git rev-list --all)
        else {
            echo "searching $location for $search"
            $sudo find $location -name "$search" | hlp "$hl"
        } fi
    }
}

function h() {
    [[ -z "$1" ]] && history || history | grep "$@"
}

# Highlight Pattern
# Works like grep but shows all lines
function hlp()
{
    if [[ "$1" != "" ]]; then
        grep -E "$1|$"
    else
        echo "usage: command -params | hlp 'highlightstring'"
        echo "For acceptable highlightstring values, see ${RED}searchcontents${D}"
    fi
}

function ipdrop() {
    iptables -A INPUT -s $1 -j DROP
}

function lastmod(){
    if [[ $os == "macOS" ]]; then echo "Last modified" $(( $(date +%s) - $(stat -f%c "$1") )) "seconds ago"
    else echo "Last modified" $(( $(date +%s) - $(date +%s -r "$1") )) "seconds ago"
    fi
}

# mkdir and cd into it
function mkcd() {
    mkdir $1
    cd $1
}

function notify() {
    notification=$'\e]9;'
    notification+=$1
    notification+=$'\007'
    echo $notification
}

function pause() {
    read -p "$*"
}

function rm () {
    local HISTIGNORE="$HISTIGNORE:command rm *"
    local arg process
    local -a sanitized
    command rm "$@"
    process=true
    for arg in "$@"; do
    if [[ $process && $arg = -*f* ]]; then
        sanitized+=("${arg//f/}")
    elif [[ $arg == -- ]]; then
        process=
    else
        sanitized+=("$arg")
    fi

    done
    history -s rm "${sanitized[@]}"
}

function scan_nmap() {
    local ip=$1
    local sudo=$2

    echo $sudo scanning ${PINK}$ip${D}
    $sudo nmap -sn -PE $ip/24
}

function scanip() {
    scan_nmap $1 $2
}

function scansubnet() {
    scan_nmap 192.168.$1.1 $2
}

function searchcontents() {
    if [[ "$1" != "" ]]; then
        echo "searching $(pwf) for '$1' (ignoring binary files, .git/, vendor/)"
        grepString="grep -"
        [[ "$2" != "0" ]] && grepString+="i"
        grepString+="Inr \"$1\" . --exclude-dir=\".git\" --exclude-dir=\"vendor\" --exclude-dir"
        [[ "$3" != "0" ]] && grepString+=" --exclude-dir=\"js\""

        eval $grepString
        count=$(eval $grepString | wc -l)

        echo "$count matches"
    else
        echo "usage: searchcontents string [bool caseInsensitive?] [bool excludeJS?]"
        echo "       searchcontents 'string with spaces' [1|0] [1|0]"
        echo "       searchcontents '\$pecial' [1|0] [1|0]"
    fi
}

function set_title() {
    t='echo -ne "\033]0;TITLE_HERE\007";'

    t=${t/TITLE_HERE/$1}
    export PROMPT_COMMAND=$t
}

function sshl() {
    local start=false
    local STATUS="$(ssh-add -l 2>&1)"
    [[ "$STATUS" == "Could not open a connection to your authentication agent." ]] && start=true
    [[ "$STATUS" == "Error connecting to agent: Connection refused" ]] && start=true

    [[ $start == true ]] && eval `keychain --eval` && STATUS="$(ssh-add -l 2>&1)"

    if [[ "$STATUS" == "The agent has no identities." ]]; then
        if [[ -f ~/.ssh/id_ed25519 ]]; then
            echo "Loading ${GREEN}ed25519${D} identity file"
            keyfile="id_ed25519"
        elif [[ -f ~/.ssh/id_rsa ]]; then
            echo "${RED}WARNING: RSA is an insecure algorithm, upgrade to ed25519${D}"
            echo "Loading ${RED}rsa${D} identity file"
            keyfile="id_rsa"
        else
            echo "No ssh identity found."
            return 1
        fi

        ssh-add ~/.ssh/$keyfile
    else
        echo "$STATUS"
    fi
}
export -f sshl

# start ssh agent(keychain or legacy) and list ssh keys
sshl

function strpos() {
    [[ -z $1 ]] && echo "usage: strpos haystack needle" || {
        x="${1%%$2*}"
        [[ $x = $1 ]] && echo -1 || echo ${#x}
    }
}

function ubash() {
    if [[ -z "$1" ]]; then
        [[ $os == "Linux" ]] || [[ $host == "RODS_Z20T" ]] && {
            # if you get a certificate error from this, put your hostname inside the following bash regex
            http_only_hosts = 'no_https_1|no_https_2'
            wget https://www.dropbox.com/s/fub5enhubrerqwk/.bashrc?dl=0 -O "$basherk_src" $([[ $host =~ ^($http_only_hosts)$ ]] && echo "--no-check-certificate")
            clear
            echo "If you're not root, ${PINK}sudo cp ~/.bashrc /root/.bashrc && sudo su${D}"
        }
        basherk
        echo "bashrc updated / re-sourced"
        lastmod "$basherk_src"
        return
    elif [[ $1 == *@* ]]; then
        pos=$(strpos $1 '@')
        user=${1:0:pos}
        ((pos++))
        host=${1:pos}
    else
        user="root"
        host=$1
        [[ $uquiet != true ]] && echo "assuming ${RED}root@${D}$host"
    fi

    [[ $uquiet == true ]] && rsync -az "$basherk_src" $user@"$host":~/.bashrc || {
        rsync -avz "$basherk_src" $user@"$host":~/.bashrc
        lastmod "$basherk_src"
        echo "For servers with ${GREEN}no root${D} login, use this to ${GREEN}sudo ubash on root${D}"
        echo "${PINK}sudo cp ~/.bashrc /root/.bashrc && sudo su${D}"
    }
}

function iTermSH() {
    [[ $os == "macOS" ]] && {
        # Help iTerm2 Semantic History by echoing current dir
        d=$'\e]1337;CurrentDir='
        d+=$(pwd)
        d+=$'\007'
        echo $d
    }
}
function echo_working_dir() {
    local dir=$1
    if [[ $(git_in_repo) == "on" ]]; then
        PWD=$(pwd)
        REPO=$(git_repo_name)

        # replace repo with colon in path for use in sed
        dir=${PWD/$REPO/:}

        # since git_repo_name uses remote name, if there's no
        # remote, we won't have a name to replace with. Also
        # cancel if remote name doesn't match directory name
        if [[ $dir == *":"* ]]; then
            # strip everything before colon using sed and prepend repo name
            dir="$REPO repo$(sed 's/.*://' <<< $dir)"
        fi
    fi

    echo $dir
}
Response=""
function git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
function git_dirty() {
    # [[ $(git status --porcelain 2> /dev/null | grep '?') != "" ]] && Response+="?"
    # [[ $(git status --porcelain 2> /dev/null | grep 'M') != "" ]] && Response+="!"
    # echo $Response
    echo ""
    # Running git status on huge repos takes ages, making every command take much longer than expected
}
function git_in_repo() {
    [[ $(git_branch) != "" ]] && echo "on"
}
function git_repo_name() {
    git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//'
}
function git_root() {
    git rev-parse --show-toplevel
}

export PS1='\n${PINK}\u \
${D}at ${ORANGE}\h \
${D}in ${GREEN}$(echo_working_dir "\w") \
${D}$(git_in_repo) ${PINK}$(git_branch)${GREEN}$(git_dirty) \
${D}$(iTermSH)\n$ '
# Mail export PS1='\n${PINK}\u ${D}at ${ORANGE}\h ${D}in ${GREEN}\w${D}\n$ '
# ESXi export PS1='\n\e[35;49m\u \e[37;49mat \e[33;49m\h \e[37;49min \e[32;49m\w\e[37;49m\n$ '

# Set window title
export PROMPT_COMMAND='echo -ne "\033]0;$USER at $(hostname) in ${PWD##*/}\007";'

# Save and reload the history after each command finishes
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\nhistory -a; history -c; history -r;'}"

# source things to be executed after basherk
[[ -f "$basherk_dir/basherk-custom.sh" ]] && . "$basherk_dir/post-basherk.sh"
