# shellcheck disable=SC1090 # ignore non-constant source location warning
# shellcheck disable=SC2119 # not a regular script, function's $1 is never script's $1
# shellcheck disable=SC2120 # not a regular script, functions define arguments we won't use here
# basherk
# .bashrc replacement
#
# tab breaks iTerm insertion character break pointer thing

# If not running interactively, don't do anything
[[ -z $PS1 ]] && return

# basherk specific
basherk_ver=133
basherk_date="12 July 2019"
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
    command -v "$1" &>/dev/null
}

# history options
export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # 100k lines of history
export HISTFILESIZE=100000              # 100kb max history size
export HISTIGNORE=" *:* --version:changed*:clear:countsize:df:f:find:gd:gds:gl:gla:graph:graphall:gs:h:h *:history:la:ls:mc:open .:ps:pwd:staged*:stashes:suho:test:time *:ubash:ubashall:gitinfo*"
export HISTTIMEFORMAT="+%Y-%m-%d.%H:%M:%S "
shopt -s histappend                     # append to history, don't overwrite
shopt -s checkwinsize                   # check the window size after each command
shopt -s cdspell                        # autocorrect for cd

# Check for interactive shell (to avoid problems with scp/rsync)
# and disable XON/XOFF to enable Ctrl-s (forward search) in bash reverse search
[[ $- == *i* ]] && stty -ixon

[[ -z $LANGUAGE ]] && export LANGUAGE=$LANG
[[ -z $LC_ALL ]] && export LC_ALL=$LANG

os=$(uname)

[[ $os == "Darwin" ]] && os="macOS"
[[ $HOSTNAME =~ (Zen|Obsidian) ]] && os="Windows"
[[ $BASH == *termux* ]] && os="Android"

[[ $os =~ (Linux|Windows) ]] && {
    alias vwmod='stat --format "%a"'
    alias linver='cat /etc/*-release'
}

# set appropriate ls color flag
if ls --color -d . &>/dev/null; then
    alias ls='ls --color=auto'
elif ls -G -d . &>/dev/null; then
    # macOS/FreeBSD/FreeNAS
    alias ls='ls -G'
fi

alias la='ls -Ahl'

# set appropriate l alias (hide owner/group if possible)
if ls -dgo . &>/dev/null; then
    alias l='la -go'
else
    # busybox ls
    alias l='la -g'
fi

# Single OS aliases
case $os in
    macOS)
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
        ;;
    Windows)
        alias elp='tailf /c/xMAMP/logs/phperror.log'
        alias suho='vi /mnt/c/Windows/System32/drivers/etc/hosts'
        ;;
esac

alias gitinfo='graphall -10 && totalcommits && echo "Repo URL: ${GREEN}$(get_repo_url)${D}" && echo && gs'

# Redefine builtin commands
alias cp='cp -iv' # interactive and verbose
alias mv='mv -iv'
# shellcheck disable=SC2032 # ignore warning that xargs rm in this script won't use this alias
alias rm='rm -iv'
alias df='df -h' # human readable
alias mkdir='mkdir -pv' # Make parent directories as needed and be verbose

# General aliases
alias back='cd "$OLDPWD"'
alias fuck='sudo $(history -p \!\!)' # Redo last command as sudo
alias lessf='less +F'
alias now='date +"%c"'
alias pwf='echo "${PWD##*/}"'
alias sudo='sudo ' # pass aliases through sudo https://serverfault.com/a/178956
alias vollist='echo && echo "pvs" && pvs && echo && echo "vgs" && vgs && echo && echo "lvs" && lvs'
alias voldisp='echo && echo "pvdisplay" && pvdisplay && echo && echo "vgdisplay" && vgdisplay && echo && echo "lvdisplay" && lvdisplay'
alias weigh='du -sch'

# conditional aliases
if ! exists tailf; then alias tailf='tail -f'; fi

if ! exists aspell; then alias aspell='hunspell'; fi

if echo x | grep --color=auto x &>/dev/null; then
    alias grep='grep --color=auto'
fi

if exists ip; then
    alias ipas='ip addr show | hlp -r ".*inet [0-9.]*"'
else
    alias ipas='ifconfig | hlp -r ".*inet [0-9.]*"'
fi

# alias repo directory automatically
[[ -d ~/dev/repos ]] && {
    alias gitr='cd ~/dev/repos'
} || {
    alias gitr='cd /var/www/html'
}

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
alias gitback='git checkout -'
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

    # overwrite default if non-existent
    if ! exists realpath; then
        utility="readlink"
    fi

    # unset flag if not accepted (use known path for compatibility check)
    if [[ "$($utility $exists_flag "/dev" 2>&1)" != "/dev" ]]; then
        exists_flag=""
    fi

    if [[ "$($utility $exists_flag "/dev" 2>&1)" != "/dev" ]]; then
        # check if it works again - this should only fire on macOS without GNU coreutils
        _basherk_realpath() {
            # https://stackoverflow.com/a/18443300

            local OURPWD LINK REALPATH
            OURPWD=$PWD

            command cd "$(dirname "$1")"

            LINK=$(readlink "$(basename "$1")")

            while [ "$LINK" ]; do
                command cd "$(dirname "$LINK")"
                LINK=$(readlink "$(basename "$1")")
            done
            REALPATH="$PWD/$(basename "$1")"
            command cd "$OURPWD"
            echo "$REALPATH"
        }
        utility="_basherk_realpath"
    fi

    # shellcheck disable=SC2139 # unconventionally use double quotes to expand variables
    alias _realpath="$utility $exists_flag"
}
alias_realpath
unset alias_realpath # avoid pollution

# credit: https://stackoverflow.com/a/17841619
# this solution avoids appending/prepending delimiter to final string
function array_join() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "Join array elements with a (multi-character) delimiter"
        echo "Usage:"
        echo "    array_join [--help]"
        echo "    array_join delimiter \${array[@]}"
        return
    }

    # capture delimiter in variable and remove from arguments array
    local delimiter="$1"
    shift

    # echo first array element to avoid prepending it with delimiter
    echo -n "$1"
    shift

    # prepend each element with delimiter
    printf "%s" "${@/#/$delimiter}"
}

# usage: if in_array "foo" "${bar[@]}"; then echo "array contains element"; fi
function in_array() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "\$1 is empty: '$1'"
        echo "Search array for matching element"
        echo "Usage:"
        echo "    in_array [--help]"
        echo "    in_array element \${array[@]}"
        return
    }

    local positional

    # capture element/needle in variable and remove from arguments array
    local element="$1"
    shift

    # loop positional parameters (array) and return true if present
    for positional; do
        if [[ "$positional" == "$element" ]]; then
            return 0
        fi
    done

    # return false
    return 1
}

function define_wsl_commands() {

    # open files directly from terminal using Windows' default program, like macOS
    alias open='cmd.exe /C start'

    # cdwsl "C:\Program Files" -> "/mnt/c/Program Files"
    function cdwsl() {
        cd "$(wslpath "$@")"
    }

    # either install sublime text to the default location, or
    # choose a custom install location and symlink it into path so we can detect it
    function sublime() {
        local sublime_which_path=$(command which sublime)
        local sublime_default_path="/mnt/c/Program Files/Sublime Text 3/subl.exe"
        local sublime_path
        local sublime_command
        local path="$@"

        if [[ -z $sublime_which_path ]]; then
            # sublime is not symlinked in path, check default install location
            if [[ -e $sublime_default_path ]]; then
                # sublime is installed to default location
                sublime_path="$sublime_default_path"
            else
                # can't find sublime, unset this function & stop polluting the shell
                echo "can't find sublime, unset this function & stop polluting the shell"
                unset sublime
            fi
        else
            # sublime is symlinked in path, wrap the symlink in a function for windows path compatibility
            sublime_path="$sublime_which_path"
        fi

        # open sublime with no arguments if none passed
        if [[ -z $path ]]; then
            echo path empty
            $sublime_path
        else
            if [[ $(wslpath -w "$(realpath "$path")" 2>&1) == *Invalid* ]]; then
                echo "Windows is not able to open this file, it's in the linux file system"
                return
            elif [[ $(dirname "$path") == "." ]]; then
                echo "dirname is . so just running string with path"
                # cmd.exe /C "$(wslpath -w "$sublime_path")" "$path"
                "$sublime_path" "$path"
            else
                echo $(
                    unset sublime
                    command cd "$(dirname "$path")"
                    # cmd.exe /C "$(wslpath -w "$sublime_path")" "$(basename "$path")"
                    sublime "$(basename "$path")"
                )
            fi
        fi
        return

        # cdfile "$path" && cmd.exe /C \"$(wslpath -w "$sublime_path")\" \"$path\" &
        # "$(wslpath -w "$path")"
        # cmd.exe /C "C:\Program Files\Sublime Text 3\subl.exe" "C:\Users\travz\downloads\kodi.crash.windows.log"
        # I think we need to $(cdfile "$@" && $runwincmd) since spaces in pwd don't matter
    }

    function map_drives() {
        local share letter

        for share in /srv/*; do
            letter="${share:5:1}"
            letter="${letter^}:"

            # avoid unnecessary remounts
            if ! mount | grep "$letter on $share" >/dev/null; then
                mount -t drvfs "$letter" "$share"
            fi

        done
    }

}

if exists wslpath; then
    define_wsl_commands
fi
unset define_wsl_commands # avoid pollution

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
    # shellcheck disable=SC2164 # don't worry about cd failure
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
    # shellcheck disable=SC2033 # ignore warning that xargs rm in this script won't use my rm function
    find . \( -iname "@eadir" -o -iname "thumbs.db" -o -iname ".ds_store" \) -print0 | xargs -0 rm -ivrf
}

# wrapper for git commit
# counts characters, checks spelling and asks to commit
# requires aspell/hunspell
function commit() {
    local len
    local message="$1"

    len=$(length -a "$message")

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
    read -r -p "Commit using this message? [y/N] " commit

    [[ $commit == "y" ]] && {
        git commit -m "$message"
    } || echo "Aborted"
}

function check_commit() {
    local commit="$1"
    local message
    local linenum=0 summary=0 longestline=0

    # shellcheck disable=SC2086 # $commit needs to be unquoted to implicitly refer
    # to the last commit, if no argument is passed to check_commit
    message=$(git log $commit -1 --pretty=%B)

    while read -r line; do
        if [[ $linenum -eq 0 ]]; then
            summary=${#line}
        else
            [[ ${#line} -gt $longestline ]] && longestline=${#line}
        fi

        ((linenum++))
    done <<< "$message"

    if [[ $summary -gt 50 ]]; then
        echo -n "Summary is ${RED}$summary characters long${D}"
    else
        echo -n "Summary is ${GREEN}$summary characters long${D}"
    fi

    if [[ $longestline -gt 72 ]]; then
        echo -n ", and longest line in body is ${RED}$longestline characters long${D}"
    else
        # only echo body length if non-zero
        [[ $longestline -ne 0 ]] && echo -n ", and longest line in body is ${GREEN}$longestline characters long${D}"
    fi

    # echo newlines to compensate for their omission above
    echo -e "\n\n${PINK}$message${D}\n"

    echo "$message" | aspell -a

    echo "If necessary, amend commit with: ${BLUE}git commit --amend${D}"
}

# compare "string1" "string2"
function compare() {
    [[ -z $1 ]] && echo "compare 2 strings" && return

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

# make f file search use tool
# reverse patch search, latest should be at the bottom, fresher in my memory for what I'm looking for
# custom find command to handle searching files, commits, file/commit contents, or PATH
function f() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "search files, commits, file/commit contents, or PATH"
        echo "usage: f location search [sudo]"
        echo
        echo "locations:"
        echo "    folders ( / . /usr )"
        echo "    path (will systematically search each folder in \$PATH)"
        echo "    in (find in file contents)"
        echo "    commit (find a commit with message matching string)"
        echo "    patch (find a patch containing change matching string/regexp)"
        echo "    patchfull (find a patch containing change matching string/regexp, and show function context)"
        echo
        echo "f in string"
        echo "f in 'string with spaces'"
        echo "f in '\$pecial'"
        return
    }

    local count matches path tool
    local location="$1"
    local search="$2"
    local sudo="$3"
    # escape all periods for highlighting pattern (grep wildcards)
    local hl="${search//./\\.}"

    # prefer ripgrep, then silver surfer, then grep if neither are installed
    if exists rg; then
        tool="rg"
    elif exists ag; then
        tool="ag"
    else
        tool="grep"
    fi

    if [[ $location == "path" ]]; then
        # search each folder in PATH with a max depth of 1

        [[ -e $search ]] && {
            echo "warning: if you specified a wildcard (*), bash interpreted it as globbing"
        }

        # add wildcards to file search if the user hasn't specified one
        [[ ! $search == *'*'* ]] && search="*$search*"

        echo "searching dirs in ${CYAN}\$PATH${D} for files matching ${CYAN}$search${D} (case insensitive)"

        local IFS=":"
        for path in $PATH; do
            # ignore non-existent directories in $PATH
            [[ ! -d $path ]] && continue

            $sudo find "$path" -maxdepth 1 -iname "$search" | hlp -i "$hl"
        done

    elif [[ $location == "in" ]]; then
        # search file contents

        if [[ $tool != "grep" ]]; then
            echo "searching ${CYAN}$(pwf)/${D} for '${CYAN}$search${D}' (case sensitive, using $tool)"
            $tool "$search"
        else
            echo "searching ${CYAN}$(pwf)/${D} for '${CYAN}$search${D}' (using $tool, ignores: case, binaries , .git/, vendor/)"
            count=$($tool -Iinr "$search" . --exclude-dir=".git" --exclude-dir="vendor" | tee /dev/tty | wc -l)

            echo "$count matches"
        fi

    elif [[ $location == "commit" ]]; then
        # find a commit with message matching string
        graphall -10000 | grep -i "$search"

    elif [[ $location == patch* ]]; then
        # find a patch containing change matching string/regexp

        [[ $location == "patchfull" ]] && local context="--function-context"

        for commit in $(git log --pretty=format:"%h" -G "$search"); do
            echo
            git log -1 "$commit" --format="%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(20,trunc)%cr%Creset %C(yellow)%d"

            # git grep the commit for the search, remove hash from each line as we echo it pretty above
            matches=$(git grep --color=always -n $context "$search" "$commit")
            echo "${matches//$commit:/}"
        done

        # display tip for patchfull
        [[ $location == "patch" ]] && echo -e "\n${GREEN}f ${*/patch/patchfull}${D} to show context (containing function)"

    else
        # location is a real file/folder location

        if [[ -d $location ]]; then
            # find files

            [[ -e $search ]] && {
                echo "warning: if you specified a wildcard (*), bash interpreted it as globbing"
            }

            # add wildcards to file search if the user hasn't specified one
            [[ ! $search == *'*'* ]] && search="*$search*"

            echo "searching ${CYAN}$(command cd "$location" && pwd)${D} for files matching ${CYAN}$search${D} (case insensitive)"

            # capture find errors in global var basherk_f_errors
            # https://stackoverflow.com/a/56577569
            { basherk_f_errors="$( { $sudo find "$location" -iname "$search" | hlp -i "$hl"; } 2>&1 1>&3 3>&- )"; } 3>&1;

            # tell user if there are hidden errors
            [[ -n $basherk_f_errors ]] && \
                echo "${CYAN}$(echo "$basherk_f_errors" | wc -l | awk '{print $1}')${D} find errors hidden (${CYAN}echo \"\$basherk_f_errors\"${D})"

        elif [[ -f $location ]]; then
            # find a string within a single file
            echo "searching ${CYAN}$location${D} contents for '${CYAN}$search${D}' (using $tool)"
            $tool "$search" "$location"
        fi

    fi
}

function format_date() {
    local input=$1
    local date

    if [[ -z $input ]]; then
        date=$(date +"%a, %h %d, %Y, %r")
    elif [[ $input =~ [0-9] ]]; then
        if [[ $os == "macOS" ]]; then
            date=$(date -r "$input" +"%a, %h %d, %Y, %r")
        else
            date=$(date -d @$input +"%a, %h %d, %Y, %r")
        fi
    else
        echo "input is not a number, sort this path out"
    fi

    echo "$date"
}

##########
# function gamex() {
#     local archive
#     local compressed_file
#     local path

#     if [[ -z $1 ]]; then
#         echo "Extract and show extracted games"
#         echo "Usage:"
#         echo "    gamex [PATH]  Extract game from PATH to dir_name.ext"
#         echo "    gamex -l      List extracted games"
#         return
#     elif [[ $1 == "-l" ]]; then
#         shift;
#         echo "placeholder: we should list folders in this directory that have been extracted"
#         return 0
#     fi

#     path="${1%/}" # trim trailing slash

#     archives=( "$path"/*.rar )

#     [[ -z ${archives[0]} ]] && {
#         echo "can't find archive"
#         return 0
#     }

#     archive=$(_realpath "${archives[0]}")
#     compressed_file=$(unrar lb "${archives[0]}")

#     unrar e "$archive" "/tmp/" && \
#     mv "/tmp/$compressed_file" "$path.${compressed_file##*.}"
# }
##########
# function gamex() {
#     local archive compressed_file source destination

#     if [[ -z $1 ]]; then
#         echo "Extract and show extracted games"
#         echo "Usage:"
#         echo "    gamex [source]  Extract game from source to dir_name.ext"
#         echo "    gamex -l      List extracted games"
#         return
#     elif [[ $1 == "-l" ]]; then
#         shift;
#         echo "placeholder: we should list folders in this directory that have been extracted"
#         return 0
#     fi

#     # trim trailing slash
#     source="${1%/}"
#     destination="${2%/}"

#     [[ -z $destination ]] && $destination="."

#     archives=( "$source"/*.rar )

#     [[ -z ${archives[0]} ]] && {
#         echo "can't find archive"
#         return 0
#     }

#     archive=$(_realpath "${archives[0]}")
#     compressed_file=$(unrar lb "${archives[0]}")

#     unrar e "$archive" "$destination/" && \
#     mv "$destination/$compressed_file" "$destination/$source.${compressed_file##*.}"
# }
##########
#
# Problem dump:
# ...         Clue The Classic Mystery Game [010029400CA20000][v0].nsp  99%

# Extracting from /srv/downloads/games/_switch/Clue.The.Classic.Mystery.Game.eShop.NSW-LiGHTFORCE/lfc-cluetheclassicmysterygame.r14

# ...         Clue The Classic Mystery Game [010029400CA20000][v0].nsp  OK
# Extracting  /mnt/e/switch/Clue The Classic Mystery Game [Clue Season Pass] [010029400CA21001][v0].nsp  OK
# All OK
# File(s) extracted to /mnt/e/switch/
# Archived file: "Clue" -> "Clue.The.Classic.Mystery.Game.eShop.NSW-LiGHTFORCE.1.Clue"
# mv: cannot stat '/mnt/e/switch/Clue': No such file or directory
# Archived file: "The" -> "Clue.The.Classic.Mystery.Game.eShop.NSW-LiGHTFORCE.2.The"
# mv: cannot stat '/mnt/e/switch/The': No such file or directory
# Archived file: "Classic" -> "Clue.The.Classic.Mystery.Game.eShop.NSW-LiGHTFORCE.3.Classic"
# mv: cannot stat '/mnt/e/switch/Classic': No such file or directory
# Archived file: "Mystery" -> "Clue.The.Classic.Mystery.Game.eShop.NSW-LiGHTFORCE.4.Mystery"
# mv: cannot stat '/mnt/e/switch/Mystery': No such file or directory
# Archived file: "Game" -> "Clue.The.Classic.Mystery.Game.eShop.NSW-LiGHTFORCE.5.Game"
# mv: cannot stat '/mnt/e/switch/Game': No such file or directory
# Archived file: "[010029400CA20000][v0].nsp" -> "Clue.The.Classic.Mystery.Game.eShop.NSW-LiGHTFORCE.6.nsp"
# mv: cannot stat '/mnt/e/switch/[010029400CA20000][v0].nsp': No such file or directory

function extract() {
    local archive file file_new_name source source_name destination
    local -a archives files

    if [[ -z $1 ]]; then
        echo "Extract and rename file(s) from archives inside a folder to the folder name"
        echo "    This will extract MyFile/rar.r00, MyFile/rar.r01... and rename the containing file(s) to MyFile.ext"
        echo "    A common scenario is needing to extract a file (or a couple) from an archive on a NAS, onto a USB or"
        echo "    external hard drive. Folders containing the rar files are named based on the contents, but the"
        echo "    contents may be generically named (random.file.txt instead of MyFile.txt like the folder)"
        echo "    If using 7zip or WinRAR, you have to open the folder and archive, wait for it to read/load, drag and"
        echo "    drop, and rename each file. This may copy the archives to a temp folder on C:\, extract the file(s)"
        echo "    to a temp folder on C:\, then move them to the destination."
        echo "    We avoid that by extracting directly from the NAS to the destination, then renames it automatically"
        echo "Usage:"
        echo "    extract [source]  Extract file(s) from source to dir_name.ext"
        echo "    extract -l        List contained file(s)"
        return
    elif [[ $1 == "-l" ]]; then
        shift;
        echo "placeholder: we should list folders in this directory that have been extracted"
        return 0
    fi

    if ! exists unrar; then
        echo "requires unrar" >&2
        return
    fi

    # trim trailing slashes
    source="${1%/}"
    destination="${2%/}"
    source_name="${source##*/}"

    [[ -z $destination ]] && destination="."

    # ensure write permissions on destination
    # TODO: this is broken, WSL says you have write permission in C:\Program Files, but touch test = Permission denied
    if [[ ! -w $destination ]]; then
        echo "directory ${RED}$folder${D} is not writable, exiting"
        return 1
    fi

    archives=( "$source"/*.rar )

    [[ -z ${archives[0]} ]] && {
        echo "can't find archive"
        return
    }

    archive=$(_realpath "${archives[0]}")
    files=( $(unrar lb "${archives[0]}") )

    unrar e "$archive" "$destination/" && \
    {
        echo "File(s) extracted to ${CYAN}$destination/${D}"

        if [[ ${#files[@]} == 1 ]]; then
            file=${files[0]}

            echo "Archived file: \"$file\" -> \"$source_name.${file##*.}\""
            mv "$destination/$file" "$destination/$source_name.${file##*.}"
            return
        fi

        local counter=1

        for file in ${files[@]}; do
            echo "Archived file: \"$file\" -> \"$source_name.$counter.${file##*.}\""
            mv "$destination/$file" "$destination/$source_name.$counter.${file##*.}"

            ((counter++))
        done
    }
}

# http://xahlee.info/comp/unicode_computing_symbols.html
# generate_keycode shift cmd L
function generate_keycode() {
    local input="$*" output

    # replace dash with space
    input="${input//-/ }"

    # replace plus with space
    input="${input//+/ }"

    # test unquoted runs the for loop on each word since it's a string array separated by space
    for char in $input; do
        case $char in
            shift)
                output+="⇧"
                ;;
            cmd|command)
                output+="⌘"
                ;;
            opt|option)
                output+="⌥"
                ;;
            left)
                output+="⬅"
                ;;
            right)
                output+="➡"
                ;;
            *)
                # usually a key character - uppercase
                output+="${char^}"
                ;;
        esac

        # echo spaces between chars for readability
        # Unicode 8->9 changed the widths of a bunch of codepoints https://gitlab.com/gnachman/iterm2/issues/6337
        # it seems macOS Catalina handles unicode spaces properly too, maybe I'll continue echoing both for compatibility
        output+=" "
    done

    echo "raw   : ${output// /}"
    echo "spaced: $output"
}

function get_repo_url() {
    # fix bitbucket links
    # ssh://git@bitbucket.org/statewidebearings/scheduled-scripts.git
    # returns
    # ssh///git@bitbucket.org/statewidebearings/scheduled-scripts
    #
    # Also amend get_repo_url to a different day to spread contributions
    #
    # Also don't return 'Repo URL:' if there's no repo
    # fatal: No such remote 'origin'
    local url
    url=$(git remote get-url origin)

    # reformat url from ssh to https if necessary
    [[ $url != http* ]] && url=$(echo "$url" | perl -pe 's/:/\//g;' -e 's/^git@/https:\/\//i;' -e 's/\.git$//i;')

    echo "$url"
}

function h() {
    # extend this to search ~/.bash_history?* too
    # the ? ensures there's a character after y and therefore:
    # ~/.bash_history: ignored
    # ~/.bash_history.old.zeus: matched
    [[ -z $1 ]] && history && return

    # prefer ripgrep, then silver surfer, then grep if neither are installed
    if exists rg; then
        tool="rg"
    elif exists ag; then
        tool="ag"
    else
        tool="grep"
    fi

    history | $tool "$@"
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
# did I fuck up ipas by allowing hlp to highlight multiple things? YES
# add -E flag back to it and skip multiplexing code
#
# Check other hlp funtions and test them
# also every time I modify a funtion i should search the file and test each function that uses it
function hlp() {
    local args=("$@")
    local grep_flags="-E"
    local regex
    local match_regex # rename this

    if [[ -z $1 ]] || [[ $1 == "--help" ]]; then
        echo "hlp - highlight pattern:"
        echo "  highlight a string or regex pattern from stdin"
        echo "  see grep for more options"
        echo
        echo "usage: <command> | hlp [options...] [pattern]"
        echo "  options:"
        echo "    -i            case-insensitive matching"
        echo "    -r            pass regex pattern directly"
        # echo "    -E            force regex matching"
        echo
        echo "  patterns:"
        echo "    foo bar           match either 'foo' or 'bar'"
        echo "    'foo bar'         match 'foo bar'"
        echo "    '\\\$foo bar'       match '\$foo bar'"
        echo "    '[0-9]{1,3}'      match 000 through 999"
        return
    elif [[ $1 == "-i" ]]; then
        shift;
        grep_flags="-iE"
    elif [[ $1 == "-r" ]]; then
        shift;
        match_regex=true
    fi

    # always grep for $ (end of line) to show all lines, by highlighting the newline character
    regex="$"

    # replace all asterisks with spaces
    # trim leading/trailing spaces with awk (and squash multiple into 1)
    args=$(echo "${@//\*/.*}" | awk '{$1=$1;print}')

    # replace remaining spaces with logical OR so searching for wildcards highlights correctly
    [[ $# != 1 ]] && args="${args// /|}"

    if [[ $match_regex == true ]]; then
        regex+="|$1"
    else
        # concatenate arguments with logical OR
        for pattern in $args; do
            regex+="|$pattern"
        done
    fi

    # echo "args: $args"
    # echo "regex: $regex"

    # echo "grep $grep_flags \"$regex\""
    grep $grep_flags "$regex"
}

function install_log() {
    local package_manager=$1

    local packages_before_install=$($package_manager list)
    local packages_after_install
    local packages_installed

    # run command passed by user
    "$@"

    packages_after_install=$($package_manager list)

    echo
    echo "Packages actually installed:"
    echo ${packages_before_install[@]} ${packages_after_install[@]} | tr ' ' '\n' | sort | uniq -u
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
        ip="$(ifconfig | sed -En 's/127.0.0.1//; s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p;')/24"
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

function length() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "Usage:"
        echo "    length \"string\"     Display the length of a given string (character count)"
        echo "    length -a \"string\"  Show length of string only (int)"
        return
    }

    # -a: just return string length
    [[ $1 == "-a" ]] && echo "${#2}" && return

    echo "string \"$1\" is ${CYAN}${#1}${D} characters long"
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
        sudo lsof -iTCP -sTCP:LISTEN -nP | grep -E "COMMAND|$pattern"
    else
        # show full info with ps and grep for ports (and UID to show header)
        # -tu show both tcp and udp
        # -l display listening sockets
        # -p display PID/Program name
        # -n don't resolve ports to names (80 => http, can't grep for port number)
        netstat -tulpn | grep -E "Active|Proto|$pattern"
    fi
}

# mkdir and cd into it
function mkcd() {
    [[ -z $1 ]] && echo "make a directory and cd into it, must provide an argument" && return

    mkdir -pv "$@"

    # shellcheck disable=SC2164 # don't worry about cd failure
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
        echo "failed: $new_location"
        return
    fi

    # capture actual final move location from first line of output, and remove quotes
    new_location=$(echo "$new_location" | head -n1 | tr -d \'\"\‘\’)
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
    read -r -p "$*"
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

function rtfm() {
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "rtfm:"
        echo "  search manual/help text/google for command and arguments"
        echo "  accepts all options/text without requiring escaping"
        echo "  actual rtfm options are prepended with --rtfm-"
        echo
        echo "usage: rtfm <command> [options...] [arguments...] [raw text...] [--rtfm-options...]"
        echo "  options:"
        echo "    --rtfm-strict     only match from the start of the line + indentation"
        echo "    --rtfm-para       TODO: use perl paragraph matching to get the entire option paragraph"
        echo "    --rtfm-#          TODO: echo context"
        echo "    --rtfm-[A|B|C]    TODO: accept grep context flags"
        echo "    --rtfm-debug      TODO: show command used to get result"
        return
    }

    local opts regex context=2
    local rtfm_opt strict use_para
    local -a long_opts raw

    # remove command from argument list
    local command_name="$1"
    shift

    while (( $# > 0 )); do
        case "$1" in
            --rtfm-*)
                rtfm_opt="${1:7:99}"

                if [[ $rtfm_opt == "strict" ]]; then
                    strict=true
                elif [[ $rtfm_opt =~ [0-9] ]]; then
                    context=$rtfm_opt
                elif [[ $rtfm_opt == "para" ]]; then
                    use_para=true
                fi

                shift
                ;;
            --*)
                # strip prepended --
                long_opts+=("${1:2:99}")
                shift
                ;;
            -*)
                # strip prepended -
                opts+="${1:1:99}"
                shift
                ;;
            *)
                raw+=("$1")
                shift
                ;;
        esac
    done

    if [[ $strict ]]; then
        echo "STRICT MODE"
        # ignore options scattered through descriptions of other options
        regex+="^ *-[$opts]|"
    elif [[ -n $opts ]]; then
        # match '[-x' or ' -x' or ',-x'
        regex+="[[ ,]-[$opts]|"
    fi

    # add long_opts to regex if specified
    [[ ${#long_opts[@]} -gt 0 ]] && regex+="--($(array_join "|" "${long_opts[@]}"))|"

    # add raw text to regex if specified
    [[ ${#raw[@]} -gt 0 ]] && regex+="($(array_join "|" "${raw[@]}"))|"

    # strip trailing |
    regex=${regex%?}

    # ideally we would add each regex to an array and join them later, but the
    # regex pattern itself needs to be quoted inline for grep to parse it properly

    if exists man; then
        # open manual if no search specified
        [[ -z $regex ]] && {
            man "$command_name"
            return
        }

        # https://askubuntu.com/a/743536
        if [[ $use_para ]]; then
            echo "paragraph mode"
            man "$command_name" | col -bx | perl -00 -ne 'print if / -a/' | hlp "\-a"
        else
            # pipe man through col to fix backspaces and tabs, and grep the output for our regex
            echo "man $command_name | col -bx | grep -E -A $context -e \"$regex\""
            man "$command_name" | col -bx | grep -E -A "$context" -e "$regex"
        fi

        # can we tee this and check for "No manual"* and move on?
        # also instead of grep -A can we grep until \r\n\r\n is found? (end of block)
    else
        "$command_name" --help | grep -E "$regex"
    fi

    # open "http://www.google.com/search?q=$@"
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

# show host fingerprints in both formats
# don't show errors for "foo is not a public key file"
function show_fingerprints() {
    echo

    for file in /etc/ssh/*.pub; do
        ssh-keygen -E md5 -lf "$file" 2>/dev/null && \
        ssh-keygen -E sha256 -lf "$file" 2>/dev/null && \
        echo
    done
}

# # The reason this function is sometimes so slow is because 1. C++, GCC, etc take 500ms to load each
# # Second reason is a bunch of them are symlinks to the others so GCC gets run multiple times
# # Need to maybe make a symlink only one, or somehow check if the OH
# for link in /usr/share/compl/*; do # this will glob to be huge, use find
#     if [[ "$(_realpath "$link" | basepath)" != /usr/share/compl/ ]]
# done
# # nah that'l be annoying, 2 array checks and a for loop
# # during the add loop, add a link check before sourcing
# [[ -l $file ]] && {
#     [[ "$(_realpath "$file")" == "/the/current/fucking/folder/im/looping/through/"* ]] && return
# }
function _source_bash_completions() {
    [[ $1 == "--help" ]] && {
        echo "Source all completion files from valid paths"
        echo "Usage:"
        echo "    _source_bash_completions [options]"
        echo "        --help        Show this screen"
        echo "        --paths       Show unique paths and exit"
        return
    }

    local -a absolutes paths
    local absolute_path file path

    # if bash_completion2 has already been sourced, skip the rest
    [[ $BASH_COMPLETION_VERSINFO == 2 ]] && return

    # https://superuser.com/a/1393343
    # https://discourse.brew.sh/t/bash-completion-2-vs-brews-auto-installed-bash-completions/2391/2
    [[ -f /usr/local/etc/profile.d/bash_completion.sh ]] && {
        source /usr/local/etc/profile.d/bash_completion.sh

        # source and re-check version, if v1, continue sourcing completions
        [[ $BASH_COMPLETION_VERSINFO == 2 ]] && return
    }

    # la /usr/local/etc/bash_completion.d/
    # ==> Caveats
    # Add the following to your ~/.bash_profile:
    # [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

    # If you'd like to use existing homebrew v1 completions, add the following before the previous line:
    # export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"

    paths=(
        /etc/bash_completion.d
        /usr/local/etc/bash_completion.d
        /usr/share/bash-completion/bash_completion.d
        /usr/share/bash-completion/completions
    )

    for path in "${paths[@]}"; do
        # ignore non-existent directories
        [[ ! -d $path ]] && continue

        # uniquify via absolute paths
        absolute_path=$(_realpath "$path")
        if ! in_array "$absolute_path" "${absolutes[@]}"; then
            absolutes+=("$absolute_path");
        fi
    done

    [[ $1 == "--paths" ]] && echo "${absolutes[@]}" && return

    for path in "${absolutes[@]}"; do
        # could run 2 loops here, one for files, just source them all
        # second for find -type s and check each one's realpath
        # would save running a stat on each file, unless find does that anyway
        # lets just time the difference
        # or do a find -type f "$path"/* -print 0 | xargs private_source_function file $1
        # or do a find -type s "$path"/* -print 0 | xargs private_source_function link $1
        for file in "$path"/*; do
            [[ -h $file ]] && {
                # if $file is a symlink to another file in this dir, don't source it again
                [[ "$(_realpath "$file")" == "$path"* ]] && {
                    continue
                }
            }

            # source "$file" || echo "_source_bash_completions error sourcing $file"
            source "$file"
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
            # dont commit this comment but:
            # don't eval ssh-agent if there's no identity
            return
        fi
    }

    if exists keychain; then
        # standard keychain only displays the first key when multiple are added
        # so make it quiet then explicitly list all keys
        eval "$(keychain --eval --quiet $key)"
        keychain -l
    else
        echo "keychain not installed, falling back to built-in ssh-agent"
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

function stash() {
    [[ $1 == "--help" ]] && {
        echo "stash:"
        echo "  Wrapper / logic function for either stashing changes via patch or stashing the current stage"
        echo
        echo "usage: stash [message]"
        return
    }

    local default_message message="$1"
    local patch_fail="
    ${D}Patch failed to complete (most likely overlapping patches preventing the stashed changes from being removed)
    See: https://stackoverflow.com/questions/5047366/why-does-git-stash-p-sometimes-fail
    Please review the resulting stash (${BLUE}stashcontents${D}) and remove from work tree manually (${BLUE}discardpatch${D})"

    default_message="WIP on $(git_branch): $(git rev-parse --short HEAD) $(git log -1 --pretty=%s)"

    [[ -z $message ]] && message="$default_message"

    # ask the user for a stash message first, it's harder to add one later
    echo "${CYAN}$message${D}"
    read -r -p "Type stash message, or continue with the above? (default: continue) " choice
    [[ -z $choice ]] || {
        message="$choice"
    }

    if git diff --quiet --exit-code --cached; then
        echo "${CYAN}Stage is empty, reverting to patch mode${D}"

        if ! git stash push --patch -m "$message"; then
            echo "$patch_fail"
        fi

        return
    fi

    read -r -p "[p]atch in changes to stash, or stash [s]taged changes? [p/s] " function
    if [[ $function == "p" ]]; then
        git stash push --patch
    elif [[ $function == "s" ]]; then
        _stashstage "$message"
    else
        echo "Aborted"
        return
    fi
}

# git stash only what is currently staged and leave everything else
# credit: https://stackoverflow.com/a/39644782
function _stashstage() {
    local message="$1"

    [[ -z $message ]] && echo "message is required, exiting" && return

    # stash everything but only keep staged files
    git stash --keep-index

    # stash staged files with requested message
    git stash push -m "$message"

    # apply the original stash to get us back to where we started
    git stash apply "stash@{1}"

    # create a temporary patch to reverse the originally staged changes and apply it
    git stash show -p | git apply -R

    # delete the temporary stash
    git stash drop "stash@{1}"
}

function strpos() {
    [[ -z $1 ]] && echo "usage: strpos haystack needle" && return

    x="${1%%$2*}"
    [[ $x = "$1" ]] && echo -1 || echo "${#x}"
}

[[ $os == "macOS" ]] && {
    # credit Justin Hileman - original (http://justinhileman.com)
    # credit Vitaly (https://gist.github.com/vitalybe/021d2aecee68178f3c52)
    # should I add a clean flag to this then don't command cd?
    # or command cd, clear it and duplicate cd functionality (which would hide the sshl etc)
    # or if opening current dir, output clean, otherwise nice cd functions?
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
        local path="$PWD" path_test
        local exec_set_title exec_commands user_command

        # test if we can cd into $1, and capture as $path if so.
        # this way we can handle cases where you're inside a symlinked folder,
        # but [[ -d ../foo ]] actaully references the literal parent folder
        path_test=$(if command cd "$1" &>/dev/null; then pwd; fi;)
        if [[ -n $path_test ]]; then
            path="$path_test"
            shift
        fi

        user_command="$*"

        # no need to cd if goal is home directory
        [[ $path != "$HOME" ]] && {
            commands+=("command cd '$path'")
        }

        commands+=("clear" "pwd")

        [[ -n $user_command ]] && {
            exec_set_title="set_title '$user_command'"
            commands+=("$user_command")
            commands+=("set_title")
        }

        exec_commands=$(array_join "; " "${commands[@]}")

        # osascript 2-space indentation due to deep nesting
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
    [[ $1 == "--help" ]] && {
        echo "Find running processes by name (task manager)"
        echo "Usage:"
        echo "    tm               Show all processes"
        echo "    tm [foo bar...]  Search for processes matching foo, bar"
        return
    }

    # join params with logical OR for regex
    local processes
    processes=$(array_join "|" "$@")

    # if no args passed, show all processes (match end of line)
    [[ -z $1 ]] && processes="$"

    # show full info with ps and grep for processes (and PID to show header)
    ps -aef | grep -E "PID|$processes"
}

if exists tmux; then
    function tmucks() {
        local status
        status=$(tmux attach 2>&1)

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
        # TODO: find out why rev-list returns 2 hashes for SELinuxProject/selinux
        #   both the same # of commits away from HEAD
        # pipe through head to provide a single commit for calculation, for now
        ref=$(git rev-list --max-parents=0 --abbrev-commit HEAD | head -1)
        override="initial"
    }

    commits=$(git rev-list "$ref".. --count)

    # increment to also include ref commit in count
    ((commits++))

    echo "${D}Commits for ${CYAN}$repo${D} starting $ref ($override): ${CYAN}$commits${D}"
}

# update basherk on another machine (or localhost if none specified)
function ubash() {
    local actual_path
    local dest="$1"
    local src="$basherk_src"

    [[ -z $dest ]] && {
        # update localhost

        [[ -n "$(command cd "$basherk_dir" && git_in_repo)" ]] && {
            echo "you are running basherk from a repo, to update:"
            echo "${BLUE}cd \"$basherk_dir\""
            echo "git pull"
            echo "basherk${D}"
            return
        }

        [[ -L $src ]] && {
            actual_path=$(_realpath "$src")

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

    if rsync -az "$src" "$dest":~/.basherk; then
        echo "$dest updated with basherk version $basherk_ver ($basherk_date)"
    else
        echo "${RED}basherk update failed for $dest${D}"
    fi
}

# extend information provided by which
function which() {
    local app="$1"
    local location

    location=$(command which "$app")

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
    local gitrepo gitroot subfolder

    gitroot=$(git_root 2>/dev/null) || {
        # return input if not in a git repo
        echo "$1"
        return
    }

    gitrepo=$(git_repo_name)
    subfolder=$(git rev-parse --show-prefix)

    # use git root folder name if git remote is blank
    [[ -z $gitrepo ]] && gitrepo="${gitroot##*/}"

    # manually build subfolder if inside .git since show-prefix returns blank
    [[ $dir == *.git* ]] && subfolder=".git${dir##*.git}"

    dir="$gitrepo repo/$subfolder"

    # trim trailing slash (in case subfolder is blank, since we append a slash after gitrepo)
    dir="${dir%/}"

    echo "$dir"
}

function git_branch() {
    git branch --no-color 2>/dev/null | sed '/^[^*]/d; s/* \(.*\)/\1/;'
}

function git_dirty() {
    local dirty untracked modified staged line

    # pass here-string to preserve variable assignment
    while read -r line; do
        # exit if no files
        [[ -z $line ]] && break

        # check for untracked files first, and skip loop if so
        [[ ${line:0:1} == "?" ]] && untracked=true && continue

        # trim prepended "1 " for staged/modified lines, keep only 2 chars
        line="${line:2:2}"

        # staged can be A/M/R/etc in first column, modified is M in second
        # simply check if each is not . which means not added, modified, etc
        [[ ${line:0:1} != "." ]] && staged=true
        [[ ${line:1:1} != "." ]] && modified=true

    done <<< "$(git status --porcelain=v2 2>/dev/null)"

    [[ $untracked ]] && dirty+="?"
    [[ $modified ]] && dirty+="!"
    [[ $staged ]] && dirty+="+"

    echo "$dirty"
}

function git_in_repo() {
    [[ -n "$(git_branch)" ]] && echo "on"
}

function git_repo_name() {
    git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///; s/\.git//;'
}

function git_root() {
    git rev-parse --show-toplevel
}

# git bash requires double quotes for prompt
if [[ -f /git-bash.exe ]]; then
    # user at host
    prompt="\n${PINK}\u ${D}at ${ORANGE}\h "

    # working dir or repo name substitute
    prompt+="${D}in ${GREEN}$(echo_working_dir "\w") "

    prompt+="${D}$(git_in_repo) ${PINK}$(git_branch)${GREEN}$(git_dirty) "

    prompt+="${D}\n\$ "
else
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
fi

export PS1=$prompt
unset prompt

# Set window title to something readable
set_title
export DISABLE_AUTO_TITLE="true"

# source post-basherk definitions
[[ -f "$basherk_dir/post-basherk.sh" ]] && . "$basherk_dir/post-basherk.sh"

# run sshl last to avoid terminating basherk when cancelling ssh passkey prompt
# if ssh-add exists start ssh agent(keychain or legacy) and list keys
if exists ssh-add; then sshl; fi
