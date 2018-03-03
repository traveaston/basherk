# basherk
# .bashrc replacement

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# basherk specific
basherk_ver=125
basherk_date="4 March 2018"
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

alias grep='grep --color=auto'

# history options
export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # 100k lines of history
export HISTFILESIZE=100000              # 100kb max history size
export HISTIGNORE=clear:countsize:df:f:find:gd:gds:staged:gdsw:gdw:gl:gla:gs:stashes:graph:graphall:h:"h *":history:la:ls:mc:"open .":ps:pwd:ubash:ubashall:"* --version":test:"time *":suho
export HISTTIMEFORMAT="+%Y-%m-%d.%H:%M:%S "
shopt -s histappend                     # append to history, don't overwrite
shopt -s cdspell                        # autocorrect for cd

# Source all bash completion scripts
[[ -d /usr/local/etc/bash_completion.d ]] && {
    for f in /usr/local/etc/bash_completion.d/*; do source $f; done
} || {
    if [ -f ~/.git-completion.bash ]; then
            . ~/.git-completion.bash
    fi
}

os="$(uname)"
host="$(hostname)"

[[ $os == "Darwin" ]] && os="macOS"
[[ $host =~ ^(Zen|Obsidian)$ ]] && os="Windows"

# Functions that require defining first
[[ $os == "macOS" ]] && alias la='ls -aGhl'
[[ $os =~ ^(Linux|Windows)$ ]] && alias la='ls -ahl --color=auto'

[[ $os =~ ^(macOS|Windows)$ ]] && {
    alias gitr='cd ~/dev/repos'
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
        alias elpg='now && tail -f /usr/local/var/log/postgres.log'

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
        alias gitr='gitcd /var/www/html'
        ;;
    Windows)
        # ~/dev is symlinked to /mnt/c/Dropbox/Web Development
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

alias gitinfo='graphall -10 && tcommits && gs'

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
alias lessf='less +F'
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
alias graphdates="git log --graph -20 --format=format:'%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(26,trunc)%ad%Creset %C(yellow)%d' --branches --remotes --tags"
alias latestcommits="git log --graph -20 --date-order --format=format:'%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d' --branches --remotes --tags"
alias stage='git add -p'
alias staged='git diff --staged'
alias unstage='git reset -q HEAD --'
alias discard='git checkout --'
alias discardpatch='git checkout -p'
alias limbs='git log --all --graph --decorate --oneline --simplify-by-decoration'
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

function cdfile() {
    cd $(dirname $1)
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

# comparefiles $file1 $file2
function comparefiles() {
    check256 $1 $(check256 $2)

    ls -ahl $1
    ls -ahl $2
}

# check256 $file [$checksum]
# show file checksum OR compare against expected checksum
function check256() {
    local actual expect file sha256

    if exists sha256sum; then {
        sha256="sha256sum"
    } elif exists shasum; then {
        sha256="shasum -a 256"
    } fi

    file=$1
    expect="$2"
    actual=$($sha256 $file | awk '{print $1}')

    [[ -z "$expect" ]] && echo $actual || {
        [[ "$expect" == "$actual" ]] && echo "${GREEN}sha256 matches${D}" ||
        echo "${RED}sha256 check failed${D}"
    }
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
        echo
        echo "f in string"
        echo "f in 'string with spaces'"
        echo "f in '\$pecial'"
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

function gitcd() {
    command cd "$1" && gitinfo
}

function h() {
    [[ -z "$1" ]] && history || history | grep "$@"
}

# Highlight Pattern
# Works like grep but shows all lines
function hlp() {
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

function lastmod() {
    if [[ $os == "macOS" ]]; then echo "Last modified" $(( $(date +%s) - $(stat -f%c "$1") )) "seconds ago"
    else echo "Last modified" $(( $(date +%s) - $(date +%s -r "$1") )) "seconds ago"
    fi
}

function maillog_search() {
    [[ -z $1 ]] && {
        echo "search though maillog"
        echo "usage: maillog_search --from user@example.com.au"
        echo "       maillog_search --to user@example.com.au"
        echo "       maillog_search --id v6A2pBDv006314"
        echo "       maillog_search --from *@example.com ${RED}Not working, use from or to without asterisk${D}"
    }
    local OPTS=`getopt -o i -l from: -l id: -l to: -- "$@"`
    if [ $? != 0 ]
    then
        exit 1
    fi

    eval set -- "$OPTS"

    while true ; do
        case "$1" in
            -i) echo "This would do a case insensitive search"; shift;;
            --from) grep $2 /var/log/maillog; shift 2;;
            --id) grep $2 /var/log/maillog | egrep -i 'from=|to=' | hlp $2; shift 2;;
            --to) grep $2 /var/log/maillog; shift 2;;
            --) shift; break;;
        esac
    done

    # echo "Args:"
    # for arg
    # do
    #     echo $arg
    # done
}

# mkdir and cd into it
function mkcd() {
    [[ -z "$1" ]] && echo "make a directory and cd into it, must provide an argument" && return

    mkdir -pv "$@"
    cd "$@"
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

function rm() {
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

# tm process1 [process2, etc]
function tm() {
    # replace spaces between params with OR regex for highlighting
    local search=$(echo "$@" | sed -e 's/ /\|/g')

    # escape grep to ensure color=always
    # grep for UID OR search to make the header show up
    ps -aef | \grep --color=always -E "UID|$search"
}

function tmucks() {
    local STATUS="$(tmux attach 2>&1)"

    # when there's already a tmux session, $() doesn't capture output,
    # it just attaches, so we only need to check if it doesn't work
    if [[ "$STATUS" == "no sessions" ]]; then {
        tmux
    } fi
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
    [[ $(git status --porcelain 2> /dev/null | grep '?') != "" ]] && Response+="?"
    [[ $(git status --porcelain 2> /dev/null | grep 'M') != "" ]] && Response+="!"
    echo $Response
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

# user at host
prompt='\n${PINK}\u ${D}at ${ORANGE}\h '

# working dir or repo name substitute
prompt+='${D}in ${GREEN}$(echo_working_dir "\w") '

if exists git; then prompt+='${D}$(git_in_repo) ${PINK}$(git_branch)${GREEN}$(git_dirty) '; fi

prompt+='${D}$(iTermSH)\n$ '

export PS1=$prompt


# Set window title
export PROMPT_COMMAND='echo -ne "\033]0;$USER at $(hostname) in ${PWD##*/}\007";'

# Save and reload the history after each command finishes
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\nhistory -a; history -c; history -r;'}"

# source things to be executed after basherk
[[ -f "$basherk_dir/basherk-custom.sh" ]] && . "$basherk_dir/post-basherk.sh"
