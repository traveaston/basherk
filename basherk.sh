# basherk
# .bashrc replacement

# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# basherk specific
basherk_ver=127
basherk_date="19 March 2018"
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
[[ $1 == "--update" ]] && ubash && return

# source pre-basherk dependencies
[[ -f "$basherk_dir/basherk-custom.sh" ]] && . "$basherk_dir/pre-basherk.sh"

# source custom basherk user definitions
[[ -f "$basherk_dir/basherk-custom.sh" ]] && . "$basherk_dir/basherk-custom.sh"

alias basherk='. "$basherk_src"'

# check if a command exists
# usage: if exists apt-get; then apt-get update; fi
# hoisted due to use in this script
function exists() {
    command -v "$1" >/dev/null 2>&1
}

alias grep='grep --color=auto'

# history options
export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # 100k lines of history
export HISTFILESIZE=100000              # 100kb max history size
export HISTIGNORE=clear:countsize:df:f:find:gd:gds:staged:gdsw:gdw:gl:gla:gs:stashes:graph:graphall:h:"h *":history:la:ls:mc:"open .":ps:pwd:ubash:ubashall:"* --version":test:"time *":suho:" *"
export HISTTIMEFORMAT="+%Y-%m-%d.%H:%M:%S "
shopt -s histappend                     # append to history, don't overwrite
shopt -s checkwinsize                   # check the window size after each command
shopt -s cdspell                        # autocorrect for cd

# Check for interactive shell (to avoid problems with scp/rsync)
# and disable XON/XOFF to enable Ctrl-s (forward search) in bash reverse search
[[ $- == *i* ]] && stty -ixon

os="$(uname)"
host="$(hostname)"

[[ $os == "Darwin" ]] && os="macOS"
[[ $host =~ ^(Zen|Obsidian)$ ]] && os="Windows"

# Functions that require defining first
[[ $os =~ ^(macOS|Windows)$ ]] && {
    alias gitr='cd ~/dev/repos'
}

[[ $os =~ ^(Linux|Windows)$ ]] && {
    alias vwmod='stat --format "%a"'
    alias linver='cat /etc/*-release'
}

alias ls='ls --color=auto'
alias la='ls -Ahl'
alias l='la -go'

# Single OS aliases
case $os in
    macOS)
        # enable colours
        alias ls='ls -G'

        alias el='now && tailf /usr/local/var/log/apache2/error_log'
        alias elm='now && tailf /var/log/mysql.log'
        alias elmnd='now && tailf /usr/local/var/log/mysqlnd.log'
        alias elpg='now && tailf /usr/local/var/log/postgres.log'

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

        alias elp='tailf /c/xMAMP/logs/phperror.log'
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
alias fuck='sudo $(history -p \!\!)' # Redo last command as sudo
alias lessf='less +F'
alias now='date +"%c"'
alias pwf='printf '%s' "${PWD##*/}"'
alias vollist='echo && echo pvs && pvs && echo && echo vgs && vgs && echo && echo lvs && lvs'
alias voldisp='echo && echo pvdisplay && pvdisplay && echo && echo vgdisplay && vgdisplay && echo && echo lvdisplay && lvdisplay'
alias weigh='du -sch'

if ! exists tailf; then alias tailf='tail -f'; fi

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

# custom find command to handle searching files, commits, file/commit contents, or PATH
function f() {
    local location=$1
    local search=$2
    local sudo=$3
    local hl=${search/\*/}
    hl=${hl/./\\.}

    [[ -z $1 ]] && {
        echo "search files, commits, file/commit contents, or PATH"
        echo "usage: f location search [sudo]"
        echo
        echo "locations:"
        echo "    folders ( / . /usr )"
        echo "    path (will systematically search each folder in \$PATH)"
        echo "    in (find in file contents)"
        echo "    commit (find a commit with message matching string)"
        echo "    patch (find a patch containing change matching string/regexp)"
        echo "    patchfull (find a patch containing change matching string/regexp, and show full context)"
        echo
        echo "f in string"
        echo "f in 'string with spaces'"
        echo "f in '\$pecial'"
        return
    }

    if [[ $location == "path" ]]; then {
        # search path, limit depth to 1 directory
        $sudo find ${PATH//:/ } -maxdepth 1 -name "$search" -print | hlp "$hl"
    } elif [[ $location == "in" ]]; then {
        # search file contents
        local args=$(echo "$@" | perl -pe 's/^in //')

        # prefer ripgrep, then silver surfer, then grep if neither are installed
        if exists rg; then {
            rg "$args"
        } elif exists ag; then {
            ag "$args"
        } else {
            echo "searching $(pwf) for '$search' (case insensitive, ignoring binary files, .git/, and vendor/)"
            count=$(grep --color=always -Iinr "$search" . --exclude-dir=".git" --exclude-dir="vendor" | tee /dev/tty | wc -l)

            echo "$count matches"
        } fi
    } elif [[ $location == "commit" ]]; then {
        # find a commit with message matching string
        graphall -10000 | grep -i "$search"
    } elif [[ $location == "patch"* ]]; then {
        # find a patch containing change matching string/regexp

        [[ $location == "patchfull" ]] && local context="--function-context"

        for commit in $(git log --pretty=format:"%h" -G "$search"); do
            echo
            git log -1 $commit --format='%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(20,trunc)%cr%Creset %C(yellow)%d'

            # git grep the commit for the search, remove hash from each line as we echo it pretty above
            local matches=$(git grep --color=always -n $context "$search" $commit)
            echo "${matches//$commit:/}"
        done

        # display tip for patchfull
        [[ $location == "patch" ]] && echo && echo "${GREEN}f ${@/patch/patchfull}${D} to show context"
    } else {
        # find files
        echo "searching $location for *$search* (case insensitive)"
        $sudo find $location -iname "*$search*" | hlp "$hl"
    } fi
}

function gitcd() {
    command cd "$1" && gitinfo
}

function h() {
    [[ -z "$1" ]] && history || history | grep "$@"
}

# _have and have are required by some bash_completion scripts
if ! exists _have; then {
    # This function checks whether we have a given program on the system.
    _have()
    {
        PATH=$PATH:/usr/sbin:/sbin:/usr/local/sbin type $1 &>/dev/null
    }
} fi
if ! exists have; then {
    # Backwards compatibility redirect to _have
    have()
    {
        unset -v have
        _have $1 && have=yes
    }
} fi

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

# movelink (move & link)
# move a file to another location, and symbolic link it back to the original location
function mvln() {
    [[ -z "$1" ]] && echo "usage like native mv: mvln oldfile newfile" && return
    [[ -z "$2" ]] && echo "Error: Must specify new location" && return

    local old_location="$1"
    local new_location="$2"

    mv -iv "$old_location" "$new_location"
    ln -s "$new_location" "$old_location"
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

# sanitize history by removing -f from rm command
# this prevents you from rerunning an old command and force removing something unintended
function rm() {
    local HISTIGNORE="$HISTIGNORE:command rm *"
    local arg process
    local -a sanitized
    command rm "$@"
    process=true

    for arg in "$@"; do
        if [[ $process && $arg == "-f" ]]; then
            # do nothing; don't add `-f` to the command in history
            :
        elif [[ $process && $arg == -*f* ]]; then
            # remove the `f` from `-rf` or similar
            sanitized+=("${arg//f/}")
        elif [[ $process && $arg == "-iv" ]]; then
            # do nothing; don't add `-iv` to the command in history
            :
        elif [[ $arg == -- ]]; then
            process=
        else
            sanitized+=("$arg")
        fi
    done

    # add sanitized command to history
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

function set_title() {
    t='echo -ne "\033]0;TITLE_HERE\007";'

    t=${t/TITLE_HERE/$1}
    export PROMPT_COMMAND=$t
}

function _source_bash_completions() {
    local -a dirs real_dirs done

    dirs=(
        /etc/bash_completion.d
        /usr/local/etc/bash_completion.d
        /usr/share/bash-completion/bash_completion.d
        /usr/share/bash-completion/completions
    )

    # use realpath to handle duplicates by symlink and remove non-existant directories
    for dir in ${dirs[@]}; do
        [[ -d $dir ]] && real_dirs+=($(realpath $dir))
    done

    for dir in ${real_dirs[@]}; do
        # check if directory has already been processed
        [[ ! " ${done[@]} " =~ " ${dir} " ]] && {
            for file in $dir/*; do
                [[ -f $file ]] && source $file
            done

            # add directory to processed array
            done+=($dir)
        }
    done

    # source other scripts if exist
    [[ -f ~/.git-completion.bash ]] && . ~/.git-completion.bash
}

_source_bash_completions

function sshl() {
    local start=false
    local STATUS="$(ssh-add -l 2>&1)"
    [[ "$STATUS" == "Could not open a connection to your authentication agent." ]] && start=true
    [[ "$STATUS" == "Error connecting to agent: Connection refused" ]] && start=true

    [[ $start == true ]] && {
        if exists keychain; then {
            eval `keychain --eval`
        } else {
            # keychain not installed, use ssh-agent instead
            eval `ssh-agent -s`
        } fi

        # re-run status check after starting agent
        STATUS="$(ssh-add -l 2>&1)"
    }

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

# if ssh-add exists start ssh agent(keychain or legacy) and list keys
if exists ssh-add; then sshl; fi

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

# update basherk
function ubash() {
    if [[ -z "$1" ]]; then
        [[ $os == "Linux" ]] || [[ $host == "RODS_Z20T" ]] && {
            # if you get a certificate error from this, put your hostname inside the following bash regex
            http_only_hosts='no_https_1|no_https_2'
            wget https://raw.githubusercontent.com/traveaston/basherk/master/basherk.sh -O "$basherk_src" $([[ $host =~ ^($http_only_hosts)$ ]] && echo "--no-check-certificate")
            clear
        }
        basherk
        echo "basherk updated: version $basherk_ver ($basherk_date)"
    else {
        # we're pushing our basherk to another machine
        if [[ $1 == *@* ]]; then
            # user@host has been specified
            pos=$(strpos $1 '@')
            user=${1:0:pos}
            ((pos++))
            host=${1:pos}
        else
            # only host has been specified
            user="root"
            host=$1
            [[ "$uquiet" != true ]] && echo "assuming ${RED}root@${D}$host"
        fi

        rsync -az "$basherk_src" $user@"$host":~/.basherk
        [[ "$uquiet" != true ]] && echo "$user@$host updated with basherk version $basherk_ver ($basherk_date)"
    }
    fi
}

# extend information provided by which
function which() {
    local app="$1"
    local location="$(command which $app)"

    echo $location # lol, i'm a bat

    # check if which returns anything, otherwise we just ls the current dir
    [[ "$location" != "" ]] && ls -ahl $location
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
