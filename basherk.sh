# basherk
# .bashrc replacement

# If not running interactively, don't do anything
[[ -z $PS1 ]] && return

# basherk specific
basherk_ver=132
basherk_date="26 March 2019"
basherk_src="${BASH_SOURCE[0]}"
basherk_dir=$(dirname "$basherk_src")
basherk_url="https://raw.githubusercontent.com/traveaston/basherk/master/basherk.sh"

# colours, credit: http://stevelosh.com/blog/2009/03/candy-colored-terminal/
D=$'\e[37;49m'
BLUE=$'\e[34;49m'
CYAN=$'\e[36;49m'
GREEN=$'\e[32;49m'
ORANGE=$'\e[33;49m'
PINK=$'\e[35;49m'
RED=$'\e[31;49m'

# show basherk version on execution
echo "basherk $basherk_ver ($basherk_date)"

[[ $1 =~ -(v|-version) ]] && return
[[ $1 == "--update" ]] && ubash && return

# source pre-basherk definitions
[[ -f "$basherk_dir/pre-basherk.sh" ]] && . "$basherk_dir/pre-basherk.sh"

# source custom basherk user definitions
[[ -f "$basherk_dir/custom-basherk.sh" ]] && . "$basherk_dir/custom-basherk.sh"

alias basherk='. "$basherk_src"'

# check if a command exists
# usage: if exists apt-get; then apt-get update; fi
# hoisted due to use in this script
function exists() {
    command -v "$1" >/dev/null 2>&1
}

# history options
export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # 100k lines of history
export HISTFILESIZE=100000              # 100kb max history size
export HISTIGNORE=" *:* --version:changed*:clear:countsize:df:f:find:gd:gds:gl:gla:graph:graphall:gs:h:h *:history:la:ls:mc:open .:ps:pwd:staged*:stashes:suho:test:time *:ubash:ubashall"
export HISTTIMEFORMAT="+%Y-%m-%d.%H:%M:%S "
shopt -s histappend                     # append to history, don't overwrite
shopt -s checkwinsize                   # check the window size after each command
shopt -s cdspell                        # autocorrect for cd

# Check for interactive shell (to avoid problems with scp/rsync)
# and disable XON/XOFF to enable Ctrl-s (forward search) in bash reverse search
[[ $- == *i* ]] && stty -ixon

os=$(uname)

[[ -f /git-bash.exe ]] && _gitbash=true

[[ $os == "Darwin" ]] && os="macOS"
[[ $HOSTNAME =~ (Zen|Obsidian) ]] && os="Windows"
[[ $BASH == *termux* ]] && os="Android"

# Functions that require defining first
[[ $os != "Android" ]] && alias grep='grep --color=auto'

[[ $os =~ (macOS|Windows) ]] && {
    alias gitr='cd ~/dev/repos'
}

[[ $os =~ (Linux|Windows) ]] && {
    alias vwmod='stat --format "%a"'
    alias linver='cat /etc/*-release'
}

alias ls='ls --color=auto'
alias la='ls -Ahl'
alias l='la -go'

# override l alias for android (busybox ls lacks -o flag)
[[ $os == "Android" ]] && alias l='la -g'

# override ls alias for FreeBSD / FreeNAS
[[ $os == "FreeBSD" ]] && alias ls='ls -G'

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
        alias el='now && tailf /usr/local/apache2/logs/error_log'
        alias gitr='cd /var/www/html'
        ;;
    Windows)
        alias elp='tailf /c/xMAMP/logs/phperror.log'
        alias suho='vi /mnt/c/Windows/System32/drivers/etc/hosts'
        ;;
esac

alias gitinfo='graphall -10 && totalcommits && echo "open repo url in browser with ${GREEN}showrepo${D}" && gs'

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

# conditional aliases
if ! exists tailf; then alias tailf='tail -f'; fi

if ! exists aspell; then alias aspell='hunspell'; fi

if exists ip; then
    alias ipas='ip addr show | hlp ".*inet [0-9.]*"'
else
    alias ipas='ifconfig | hlp ".*inet [0-9.]*"'
fi

# Custom commands
alias travmysql='mysql -u trav -p'
alias mysql_shutdown='mysqladmin -u trav -p shutdown'
alias elmd='now && tailf /var/log/mysqld.log'
alias openports='nmap -sT -O localhost'

# Git aliases
alias changed='git diff'
alias changedchars='git diff --color-words=.'
alias changedwords='git diff --color-words'
alias gb='git branch -a'
alias gd='git diff'
alias gdom='git diff origin/master'
alias gds='staged'
alias gl='graph'
alias gla='graphall'
alias gnb='git checkout -b'
alias gs='git status'
alias stashes='git stash list'
alias gsl='stashes'
alias gitsquashlast='git rebase -i HEAD~2'
alias graph='git log --graph -14 --format=format:"%Cgreen%h%Creset - %<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d"'
alias graphall='git log --graph -20 --format=format:"%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d" --branches --remotes --tags'
alias graphdates='git log --graph -20 --format=format:"%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(26,trunc)%ad%Creset %C(yellow)%d" --branches --remotes --tags'
alias latestcommits='git log --graph -20 --date-order --format=format:"%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d" --branches --remotes --tags'
alias stage='git add -p'
alias staged='git diff --staged'
alias stagedchars='git diff --staged --color-words=.'
alias stagedwords='git diff --staged --color-words'
alias stashcontents='git stash show -p'
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

# alias realpath for consistency
function alias_realpath() {
    local utility="realpath"
    local exists_flag="-e"

    # overwrite default if non-existant
    if ! exists realpath; then
        utility="readlink"
    fi

    # unset flag if not accepted
    if [[ "$($utility $exists_flag 2>&1)" =~ (invalid|illegal) ]]; then
        exists_flag=""
    fi

    # shellcheck disable=SC2139 # unconventionally use double quotes to expand variables
    alias _realpath="$utility $exists_flag"
}
alias_realpath
unset alias_realpath # avoid pollution

# credit: https://stackoverflow.com/a/17841619
function array_join() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "Join array elements with a (multi-character) delimiter"
        echo "Usage:"
        echo "    array_join [--help]"
        echo "    array_join delim array"
        return
    }

    local d="$1"
    shift
    echo -n "$1"
    shift
    printf "%s" "${@/#/$d}"
}

function cd() {
    local old_dir="$PWD"
    local new_dir="$1"

    # go home if directory not specified
    [[ -z $new_dir ]] && new_dir=~

    # escape cd to avoid calling itself or other alias
    command cd "$new_dir"

    # don't run other commands if we didn't actually change directory
    [[ $old_dir == "$PWD" ]] && return

    # print working directory and list contents
    pwd
    l

    # run gitinfo if .git directory exists
    [[ -d .git ]] && gitinfo
}

function cdfile() {
    cd "$(dirname "$1")"
}

# check256 $file [$checksum]
# show file checksum OR compare against expected checksum
function check256() {
    local actual expect file sha256

    if exists sha256sum; then
        sha256="sha256sum"
    elif exists shasum; then
        sha256="shasum -a 256"
    fi

    file="$1"
    expect="$2"
    actual=$($sha256 "$file" | awk '{print $1}')

    if [[ -z $expect ]]; then
        echo "$actual"
    else
        if [[ $expect == "$actual" ]]; then
            echo "${GREEN}sha256 matches${D}"
        else
            echo "${RED}sha256 check failed${D}"
        fi
    fi
}

# remove annoying synology, windows, macos files
function cleanup_files() {
    find . \( -iname "@eadir" -o -iname "thumbs.db" -o -iname ".ds_store" \) -print0 | xargs -0 rm -ivrf
}

# commit
# wrapper for git commit
# counts characters, checks spelling and asks to commit
function commit() {
    local message="$1"
    local len=$(length -a "$message")

    [[ $len -gt 50 ]] && {
        echo "${RED}$len characters long${D}"
        echo "truncated to 50: '${BLUE}${message:0:50}${D}'"
        return
    }

    [[ $len == 0 ]] && {
        # commit with editor and if command succeeds, check spelling
        git commit -e && check_commit
        return
    }

    echo "${GREEN}$len characters long${D}"

    echo
    echo "${BLUE}Spell check:${D}"
    echo "$message" | aspell -a

    echo "git commit -m ${PINK}\"$message\"${D}"
    read -p "Commit using this message? [y/N] " commit

    [[ $commit == "y" ]] && {
        git commit -m "$message"
    } || echo "Aborted"
}

function check_commit() {
    local commit="$1"
    local message=$(git log "$commit" -1 --pretty=%B)

    echo
    echo "${PINK}$message${D}"
    echo
    echo "$message" | aspell -a

    echo "If necessary, amend commit with: ${BLUE}git commit --amend${D}"
}

# Compare 2 strings
function compare() {
    [[ -z $1 ]] && exit

    [[ $1 == "$2" ]] && echo "${GREEN}2 strings match${D}" ||
    echo "${RED}Strings don't match${D}"
}

# comparefiles $file1 $file2
function comparefiles() {
    check256 "$1" "$(check256 "$2")"

    ls -ahl "$1"
    ls -ahl "$2"
}

# cpmod $file1 $file2
# copy file mode / permissions from one file to another
# in other words set file2 permissions identical to file1
function cpmod() {
    chmod "$(vwmod "$1")" "$2"
}

# custom find command to handle searching files, commits, file/commit contents, or PATH
function f() {
    local location="$1"
    local search="$2"
    local tool
    local sudo="$3"
    # escape all periods for highlighting pattern (grep wildcards)
    local hl="${search//./\\.}"

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

    # prefer ripgrep, then silver surfer, then grep if neither are installed
    if exists rg; then
        tool="rg"
    elif exists ag; then
        tool="ag"
    else
        tool="grep"
    fi

    if [[ $location == "path" ]]; then {
        # search path, limit depth to 1 directory
        # shellcheck disable=SC2086 # PATH substitution needs to be unquoted to glob for find cmd
        $sudo find ${PATH//:/ } -maxdepth 1 -name "$search" -print | hlp "$hl"
    } elif [[ $location == "in" ]]; then {
        # search file contents
        local args=$(echo "$@" | perl -pe 's/^in //')

        if [[ $tool != "grep" ]]; then
            echo "searching ${CYAN}$(pwf)${D} for '${CYAN}$search${D}' (using $tool)"
            $tool "$args"
        else
            echo "searching ${CYAN}$(pwf)${D} for '${CYAN}$search${D}' (using $tool, ignores: case, binaries , .git/, vendor/)"
            count=$($tool --color=always -Iinr "$args" . --exclude-dir=".git" --exclude-dir="vendor" | tee /dev/tty | wc -l)

            echo "$count matches"
        fi
    } elif [[ $location == "commit" ]]; then {
        # find a commit with message matching string
        graphall -10000 | grep -i "$search"
    } elif [[ $location == patch* ]]; then {
        # find a patch containing change matching string/regexp

        [[ $location == "patchfull" ]] && local context="--function-context"

        for commit in $(git log --pretty=format:"%h" -G "$search"); do
            echo
            git log -1 "$commit" --format="%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(20,trunc)%cr%Creset %C(yellow)%d"

            # git grep the commit for the search, remove hash from each line as we echo it pretty above
            local matches=$(git grep --color=always -n $context "$search" "$commit")
            echo "${matches//$commit:/}"
        done

        # display tip for patchfull
        [[ $location == "patch" ]] && echo && echo "${GREEN}f ${@/patch/patchfull}${D} to show context"
    } else {
        if [[ -d $location ]]; then {
            # find files

            [[ -e $search ]] && {
                echo "warning: if you specified a wildcard (*), bash interpreted it as globbing"
            }

            # add wildcards to file search if the user hasn't specified one
            [[ ! $search == *'*'* ]] && search="*$search*"

            echo "searching ${CYAN}$(command cd "$location" && pwd)${D} for files matching ${CYAN}$search${D} (case insensitive)"
            $sudo find "$location" -iname "$search" | hlp -i "$hl"
        } elif [[ -f $location ]]; then {
            # find a string within a single file
            echo "searching file for string"
            $tool "$search" "$location"
        } fi
    } fi
}

function h() {
    [[ -z $1 ]] && history && return

    history | grep "$@"
}

# _have and have are required by some bash_completion scripts
if ! exists _have; then
    # This function checks whether we have a given program on the system.
    _have() {
        PATH=$PATH:/usr/sbin:/sbin:/usr/local/sbin type $1 &>/dev/null
    }
fi
if ! exists have; then
    # Backwards compatibility redirect to _have
    have() {
        unset -v have
        _have $1 && have=yes
    }
fi

# Highlight Pattern
# Works like grep but shows all lines
# -i for case insensitive
function hlp() {
    local args
    local regex
    local flags="-E"

    if [[ -z $1 ]]; then
        echo "usage: command -params | hlp foo Bar"
        echo "       command -params | hlp -i foo bar"
        echo "       command -params | hlp 'foo bar'"
        echo "       command -params | hlp '\$foobar'"
        return
    elif [[ $1 == "-i" ]]; then
        shift;
        flags="-iE"
    fi

    # always grep for $ (end of line) to show all lines, by highlighting the newline character
    regex="$"

    # replace all asterisks with spaces
    # trim leading/trailing spaces with awk (and squash multiple into 1)
    args=$(echo "${@//\*/ }" | awk '{$1=$1;print}')

    # replace remaining spaces with logical OR so searching for wildcards highlights correctly
    args="${args// /|}"

    # concatenate arguments with logical OR
    for pattern in $args; do
        regex+="|$pattern"
    done

    # escape grep to ensure color=always
    \grep --color=always $flags "$regex"
}

function ipdrop() {
    iptables -A INPUT -s "$1" -j DROP
}

function ipscan() {
    [[ $1 == "--help" ]] && {
        echo "Scan IP address or subnet with sudo passthrough for ICMP"
        echo "Usage:"
        echo "    ipscan                   Scan current subnet based on local IP"
        echo "    ipscan [ip]              Scan IP address e.g. ipscan 192.168.25.50"
        echo "    ipscan [ip/netmask]      Scan IP with netmask e.g. ipscan 192.168.25.50/28"
        echo "    ipscan [subnet]          Scan subnet e.g. ipscan 25"
        echo "    ipscan [addr] [sudo]     Scan address (IP or subnet) using sudo (ICMP rather than TCP pingscan)"
        return
    }

    local ip="$1"
    local sudo="$2"

    [[ -z $ip ]] && {
        # scan subnet using local ip address with /24 subnet mask
        ip="$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')/24"
    }

    # if only subnet was given, build a complete address
    local re='^[0-9]{1,3}$'
    [[ $ip =~ $re ]] && ip="192.168.$ip.1/24"

    echo "$sudo scanning ${CYAN}$ip${D}"
    $sudo nmap -sn -PE "$ip"
}

function lastmod() {
    if [[ $os == "macOS" ]]; then echo "Last modified" $(( $(date +%s) - $(stat -f%c "$1") )) "seconds ago"
    else echo "Last modified" $(( $(date +%s) - $(date +%s -r "$1") )) "seconds ago"
    fi
}

# Display the length of a given string (character count)
function length() {
    local OPTIND

    while getopts "a:" opt; do
        case $opt in
            a)
                echo ${#OPTARG}
                return
                ;;
        esac
    done

    echo "string is ${CYAN}${#1}${D} characters long"
}

function listening() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "Find port or process in list of listening ports"
        echo "Usage:"
        echo "    listening [--help]      Show this screen"
        echo "    listening p1 [p2, etc]  Show ports/processes matching p#"
        return
    }

    local args=("$@")
    local pattern

    # regex for int with 1-5 characters
    local int_regex='^[0-9]{1,5}$'

    for (( i = 0; i < ${#args[@]}; i++ )); do
        # prepend colon to integer(port) to avoid searching PID, etc
        [[ ${args[$i]} =~ $int_regex ]] && args[$i]=":${args[$i]}"
    done

    pattern=$(array_join "|" "${args[@]}")

    if [[ $os == "macOS" ]]; then
        # show full info with ps and grep for ports (and COMMAND to show header)
        sudo lsof -iTCP -sTCP:LISTEN -nP | command grep --color=always -E "COMMAND|$pattern"
    else
        # show full info with ps and grep for ports (and UID to show header)
        # -tu show both tcp and udp
        # -l display listening sockets
        # -p display PID/Program name
        # -n don't resolve ports to names (80 => http, can't grep for port number)
        netstat -tulpn | command grep --color=always -E "Active|Proto|$pattern"
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
    local OPTS=$(getopt -o i -l from: -l id: -l to: -- "$@")
    if [ $? != 0 ]
    then
        exit 1
    fi

    eval set -- "$OPTS"

    while true ; do
        case "$1" in
            -i) echo "This would do a case insensitive search"; shift;;
            --from) grep "$2" /var/log/maillog; shift 2;;
            --id) grep "$2" /var/log/maillog | egrep -i "from=|to=" | hlp "$2"; shift 2;;
            --to) grep "$2" /var/log/maillog; shift 2;;
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
    [[ -z $1 ]] && echo "make a directory and cd into it, must provide an argument" && return

    mkdir -pv "$@"
    cd "$@"
}

# movelink (move & link)
# move a file to another location, and symbolic link it back to the original location
function mvln() {
    [[ -z $1 ]] && echo "usage like native mv: mvln oldfile newfile" && return
    [[ -z $2 ]] && echo "Error: Must specify new location" && return

    local old_location="$1"
    local new_location="$2"

    if ! new_location=$(mv -iv "$old_location" "$new_location"); then
        # return before symlinking if move fails
        return
    fi

    # capture actual final move location from first line of output, and remove quotes
    new_location=$(echo "$new_location" | head -n1 | tr -d \'\")
    # remove everything before "-> "
    new_location="${new_location##*-> }"

    ln -s "$new_location" "$old_location"

    # show results, and for directories, show name(with trailing slash) instead of contents
    la -dp "$old_location"
    la -dp "$new_location"
}

function notify() {
    notification=$'\e]9;'
    notification+="$1"
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

# set_title $title
# set window title to $title, or "user at host in folder" if blank
# ensures prompt command is not overwritten
function set_title() {
    # shellcheck disable=SC2016 # use single quotes for prompt command, variable expansion must happen at runtime
    local pcmd='echo -ne "\033]0;$USER at ${HOSTNAME%%.*} in ${PWD##*/}\007";'
    # hostname is truncated before first period
    # folder is truncated after last slash

    [[ -n $1 ]] && {
        pcmd='echo -ne "\033]0;TITLE_HERE\007";'
        pcmd=${pcmd/TITLE_HERE/$1}
    }

    # Save and reload the history after each command finishes
    pcmd="history -a; history -c; history -r; $pcmd"

    export PROMPT_COMMAND=$pcmd
}

function showrepo() {
    local url=$(git remote get-url origin)

    # reformat url from ssh to https if necessary
    [[ $url != http* ]] && url=$(echo "$url" | perl -pe 's/:/\//g;' -e 's/^git@/https:\/\//i;' -e 's/\.git$//i;')

    open "$url"
}

function _source_bash_completions() {
    local -a paths absolutes
    local absolute_path filecount limit=250

    if [[ $1 == "--help" ]]; then
        echo "Source all completion files from valid paths"
        echo "Usage:"
        echo "    _source_bash_completions [options]"
        echo "        --help               Show this screen"
        echo "        -f, --force          Don't skip paths containing >250 files"
        return
    elif [[ $1 == "-f" ]] || [[ $1 == "--force" ]]; then
        shift
        limit=10000
    fi

    paths=(
        /etc/bash_completion.d
        /usr/local/etc/bash_completion.d
        /usr/share/bash-completion/bash_completion.d
        /usr/share/bash-completion/completions
    )

    for path in "${paths[@]}"; do
        # ignore non-existant directories
        [[ ! -d $path ]] && continue

        # uniquify via absolute paths
        absolute_path="$(_realpath "$path")"
        [[ ! " ${absolutes[@]} " =~ " ${absolute_path} " ]] && absolutes+=("$absolute_path")
    done

    for path in "${absolutes[@]}"; do
        filecount=$(ls -1 "$path" | wc -l)

        [[ $filecount -gt $limit ]] && {
            echo "Skipping $filecount completions in $path"
            continue
        }

        for file in "$path"/*; do
            [[ -f $file ]] && {
                source "$file" || echo "_source_bash_completions error sourcing $file"
            }
        done
    done

    # source other scripts if exist
    [[ -f ~/.git-completion.bash ]] && source ~/.git-completion.bash
}

_source_bash_completions

function sshl() {
    local key="$1"

    # autodetect key if none specified
    [[ -z $key ]] && {
        if [[ -f ~/.ssh/id_ed25519 ]]; then
            key="id_ed25519"
        elif [[ -f ~/.ssh/id_rsa ]]; then
            key="id_rsa"
        else
            echo "No ssh identity found."
        fi
    }

    if exists keychain; then
        # standard keychain only displays the first key when multiple are added
        # so make it quiet then explicitly list all keys
        eval "$(keychain --eval --quiet $key)"
        keychain -l
    else
        # keychain not installed, use ssh-agent instead
        eval "$(ssh-agent -s)"

        # allow relative or absolute key path argument
        if [[ -f ~/.ssh/$key ]]; then
            ssh-add ~/.ssh/$key
        else
            ssh-add $key
        fi

        ssh-add -l
    fi
}
export -f sshl

# if ssh-add exists start ssh agent(keychain or legacy) and list keys
if exists ssh-add; then sshl; fi

function strpos() {
    [[ -z $1 ]] && echo "usage: strpos haystack needle" && return

    x="${1%%$2*}"
    [[ $x = "$1" ]] && echo -1 || echo "${#x}"
}

[[ $os == "macOS" ]] && {
    # credit Justin Hileman - original (http://justinhileman.com)
    # credit Vitaly (https://gist.github.com/vitalybe/021d2aecee68178f3c52)
    function tab() {
        [[ $1 == "--help" ]] && {
            echo "Open new iTerm tabs from the command line"
            echo "Usage:"
            echo "    tab                   Opens the current directory in a new tab"
            echo "    tab [PATH]            Open PATH in a new tab (includes symlinks)"
            echo "    tab [CMD]             Open a new tab and execute CMD (also sets tab title)"
            echo "    tab [PATH] [CMD] ...  You can prob'ly guess"
            return
        }

        local commands=()
        local path="$PWD"
        local args="$@"
        local exec_set_title exec_commands

        # if first argument is directory or symlink to exising directory
        if [[ -d $1 ]] || [[ -L $1 && -d "$(_realpath "$1")" ]]; then
            path=$(command cd "$1"; pwd)
            args="${@:2}"
        fi

        # no need to cd if goal is home directory
        [[ $path != "$HOME" ]] && {
            commands+=("command cd '$path'")
        }

        commands+=("clear" "pwd")

        if [ -n "$args" ]; then
            exec_set_title="set_title '$args'"
            commands+=("$args")
            commands+=("set_title")
        fi

        exec_commands=$(array_join "; " "${commands[@]}")

        osascript &>/dev/null <<EOF
          tell application "iTerm"
            tell current window
              set newTab to (create tab with default profile)
              tell newTab
                tell current session
                  write text " $exec_set_title"
                  write text " $exec_commands"
                end tell
              end tell
            end tell
          end tell
EOF
    }
}

function tm() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "Find running processes by name (task manager)"
        echo "Usage:"
        echo "    tm [--help]      Show this screen"
        echo "    tm p1 [p2, etc]  Show processes with name matching p#"
        return
    }

    # join params with logical OR for regex
    local processes
    processes=$(array_join "|" "$@")

    # show full info with ps and grep for processes (and UID to show header)
    ps -aef | command grep --color=always -E "UID|$processes"
}

if exists tmux; then
    function tmucks() {
        local status=$(tmux attach 2>&1)

        # when there's already a tmux session, $() doesn't capture output,
        # it just attaches, so we only need to check if it doesn't work
        if [[ $status == "no sessions" ]]; then
            tmux
        fi
    }
fi

function totalcommits() {
    local override="custom"
    local ref repo
    local -i commits

    # get git repo name from remote, or use folder name if empty
    repo=$(git_repo_name)
    [[ -z $repo ]] && repo=$(pwf)

    # allow overriding starting commit, if you inherit a project or similar
    # set using: git config basherk.firstcommit <ref>
    # ref is any git-readable reference (sha, tag, branch, etc)
    ref=$(git config --local --get basherk.firstcommit)

    # reference initial commit if override is absent
    [[ -z $ref ]] && {
        ref=$(git rev-list --max-parents=0 --abbrev-commit HEAD)
        override="initial"
    }

    commits=$(git rev-list "$ref".. --count)

    # increment to also include ref commit in count
    ((commits++))

    echo "${D}Commits for ${CYAN}$repo${D} starting $ref ($override): ${CYAN}$commits${D}"
}

# update basherk on another machine (or localhost if none specified)
function ubash() {
    local dest="$1"
    local src="$basherk_src"

    [[ -z $1 ]] && {
        # update localhost

        [[ -n "$(command cd "$basherk_dir" && git_in_repo)" ]] && {
            echo "you are running basherk from a repo, to update:"
            echo "${BLUE}cd \"$basherk_dir\""
            echo "git pull"
            echo "basherk${D}"
            return
        }

        [[ -L $src ]] && {
            local actual_path=$(_realpath "$src")
            echo "basherk is a symlink, updating it"
            la "$src"

            # if actual file is writable, set it as the location for curl
            [[ -w $actual_path ]] && src="$actual_path"
        }

        # download latest (HEAD) basherk
        curl $basherk_url -o "$src"
        clear

        echo "re-sourcing basherk"
        basherk
        return
    }

    [[ $dest != *@* ]] && echo "Please specify user@host" && return

    rsync -az "$src" "$dest":~/.basherk && {
        echo "$dest updated with basherk version $basherk_ver ($basherk_date)"
    } || {
        echo "basherk update failed for $dest"
    }
}

# extend information provided by which
function which() {
    local app="$1"
    local location=$(command which "$app")

    echo "$location" # lol, i'm a bat

    # check if which returns anything, otherwise we just ls the current dir
    [[ -n $location ]] && ls -ahl "$location"
}

function iTermSH() {
    [[ $os != "macOS" ]] && return

    # Help iTerm2 Semantic History by echoing current dir
    d=$'\e]1337;CurrentDir='
    d+=$(pwd)
    d+=$'\007'

    echo $d
}

# return working directory with gitroot path replaced with repo name (if necessary)
# ~/dev/repos/basherk/test => basherk repo/test
function echo_working_dir() {
    local dir="$1"
    local gitrepo subfolder

    # return input if not in a git repo
    [[ -z "$(git_in_repo)" ]] && echo "$1" && return

    gitrepo=$(git_repo_name)
    subfolder=$(git rev-parse --show-prefix)

    # return input if repo name is blank
    [[ -z $gitrepo ]] && echo "$1" && return

    # manually build subfolder if inside .git since show-prefix returns blank
    [[ $dir == *.git* ]] && subfolder=".git${dir##*.git}"

    dir="$gitrepo repo/$subfolder"

    # trim trailing slash (in case subfolder is blank, since we append a slash after gitrepo)
    dir="${dir%/}"

    echo "$dir"
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
    [[ -n "$(git_branch)" ]] && echo "on"
}

function git_repo_name() {
    git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//'
}

function git_root() {
    git rev-parse --show-toplevel
}

# git bash requires double quotes for prompt
if [[ $_gitbash == true ]]; then {
    # user at host
    prompt="\n${PINK}\u ${D}at ${ORANGE}\h "

    # working dir or repo name substitute
    prompt+="${D}in ${GREEN}$(echo_working_dir "\w") "

    prompt+="${D}$(git_in_repo) ${PINK}$(git_branch)${GREEN}$(git_dirty) "

    prompt+="${D}\n\$ "
} else {
    # shellcheck disable=SC2016 # prompt command requires single quotes
    # user at host
    prompt='\n${PINK}\u ${D}at ${ORANGE}\h '

    # shellcheck disable=SC2016 # prompt command requires single quotes
    # working dir or repo name substitute
    prompt+='${D}in ${GREEN}$(echo_working_dir "\w") '

    # shellcheck disable=SC2016 # prompt command requires single quotes
    if exists git; then prompt+='${D}$(git_in_repo) ${PINK}$(git_branch)${GREEN}$(git_dirty) '; fi

    # shellcheck disable=SC2016 # prompt command requires single quotes
    prompt+='${D}$(iTermSH)\n\$ '
} fi

# unset flag to ensure other terminals don't use incorrect code
unset _gitbash

export PS1=$prompt
unset prompt

# Set window title to something readable
set_title
export DISABLE_AUTO_TITLE="true"

# source post-basherk definitions
[[ -f "$basherk_dir/post-basherk.sh" ]] && . "$basherk_dir/post-basherk.sh"
