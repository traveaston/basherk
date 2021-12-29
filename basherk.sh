# shellcheck disable=SC1090 # ignore non-constant source location warning
# basherk
# .bashrc replacement


#################### Start basherk setup code ####################

# If not running interactively, don't do anything
[[ -z $PS1 ]] && return

# if version is already set, we are re-sourcing basherk
[[ -n $basherk_ver ]] && basherk_re_sourcing=true

basherk_ver=135
basherk_date="12 May 2021"
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

# show basherk version (including time since modified if bleeding-edge) on execution
if [[ $basherk_ver == *bleeding* ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "basherk $basherk_ver (modified $(stat -f "%Sm" -t "%a %e %b %r" "$basherk_src")," $(( $(date +%s) - $(stat -f%c "$basherk_src") )) "seconds ago)"
    else
        echo "basherk $basherk_ver (modified $(date "+%a %e %b %r" -r "$basherk_src")," $(( $(date +%s) - $(date +%s -r "$basherk_src") )) "seconds ago)"
    fi
else
    echo "basherk $basherk_ver ($basherk_date)"
fi

alias basherk='. "$basherk_src"'

[[ $1 =~ -(v|-version) ]] && return
[[ $1 == "--update" ]] && ubash && return

# this is not idempotent
[[ $1 == "--install" ]] && {
    # add preceeding newline if bashrc already exists
    [[ -f ~/.bashrc ]] && basherk_install_string="\n"

    basherk_install_string+=". $basherk_src # source basherk\n"

    echo -e "$basherk_install_string" >> ~/.bashrc
    return
}

# source pre-basherk definitions
[[ -f "$basherk_dir/pre-basherk.sh" ]] && . "$basherk_dir/pre-basherk.sh"

# source custom basherk user definitions
[[ -f "$basherk_dir/custom-basherk.sh" ]] && . "$basherk_dir/custom-basherk.sh"

#################### End basherk setup code ####################


#################### History / terminal options ####################

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


#################### Aliases ####################

os=$(uname)

[[ $os == "Darwin" ]] && os="macOS"
[[ $HOSTNAME =~ (Zen|Obsidian) ]] && os="Windows"
[[ $BASH == *termux* ]] && os="Android"


########## Redefine builtin commands (interactive/verbose for file operations)
#
alias cp='cp -iv'
alias df='df -h' # human readable
alias mkdir='mkdir -pv' # Make parent directories as needed and be verbose
alias mv='mv -iv'
alias sudo='sudo ' # pass aliases through sudo https://serverfault.com/a/178956

# shellcheck disable=SC2032 # ignore warning that other functions in this script won't use this alias
alias rm='rm -iv'


########## General aliases
alias back='cd "$OLDPWD"'
alias fuck='sudo $(history -p \!\!)' # Redo last command as sudo
alias gitr='cd ~/dev/repos' # open main git repo directory
alias lessf='less +F'
alias now='date +"%c"'
alias openports='nmap -sT -O localhost'
# shellcheck disable=SC2262 # we don't use this in the same parsing unit
alias pwf='echo "${PWD##*/}"' # print working folder
alias weigh='du -sch'


########## Git aliases
alias branches='git branch -a'
alias discard='git checkout --'
alias discardpatch='git checkout -p'
alias gb='git branch -a'
alias gitback='git checkout -'
alias gitsquashlast='git rebase -i HEAD~2'
alias gnb='git checkout -b'
alias gs='git status'
alias localbranches='git branch'
alias stage='git add -p'
alias stashcontents='git stash show -p'
alias stashes='git stash list'
alias unstage='git reset -q HEAD --'


########## Git diff aliases
alias changed='git diff'
alias changedchars='git diff --color-words=.'
alias changedwords='git diff --color-words'
alias gd='git diff'
alias gdom='git diff origin/master'
alias staged='git diff --staged'
alias stagedchars='git diff --staged --color-words=.'
alias stagedwords='git diff --staged --color-words'


########## Git log aliases
alias gl='graph'
alias gla='graphall' # git 2.9.3 seems to truncate SHAs to 7, rather than 2.26.2's 9
alias graph='git log --graph -14 --format=format:"%Cgreen%h%Creset - %<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d"'
alias graphall='git log --graph -20 --format=format:"%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d" --branches --remotes --tags'
alias graphdates='git log --graph -20 --format=format:"%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(26,trunc)%ad%Creset %C(yellow)%d" --branches --remotes --tags'
alias latestcommits='git log --graph -20 --date-order --format=format:"%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(14,trunc)%cr%Creset %C(yellow)%d" --branches --remotes --tags'
alias limbs='git log --all --graph --decorate --oneline --simplify-by-decoration'


########## Git reminder aliases / instructions
alias gitdeleteremotebranch='echo "to delete remote branch, ${PINK}git push origin :<branchName>"'
alias gitprune='echo "git remote prune origin" will automatically prune all branches that no longer exist'
alias gitrebase='echo -e "usage: git checkout ${GREEN}develop${D}\n       git rebase ${PINK}master${D}\n\nRebase ${GREEN}branch${D} onto ${PINK}base${D}, which can be any kind of commit reference:\nan ID, branch name, tag or relative reference to HEAD."'
alias gitundocommit='echo "git reset --soft HEAD^"'
alias nevermind='echo "You will have to ${RED}git reset --hard HEAD && git clean -d -f${D} but it removes untracked things like vendor"'


#################### Conditional aliases / functions ####################

function exists() { # hoisted
    [[ -z $1 ]] || [[ $1 == "--help" ]] && {
        echo "Check if a command exists"
        echo "Usage:"
        echo "    if exists apt-get; then apt-get update; fi"
        return
    }

    # return false if git is apple's xcode wrapper
    [[ "$1" == "git" ]] && [[ $(cat "$(command which git)" 2>/dev/null | grep xcode) ]] && return 1

    command -v "$1" &>/dev/null
}

if ! exists aspell; then alias aspell='hunspell'; fi
if ! exists tailf; then alias tailf='tail -f'; fi

if exists ip; then
    alias ipas='ip addr show | hlp ".*inet [0-9.]*"'
else
    alias ipas='ifconfig | hlp ".*inet [0-9.]*"'
fi

if echo x | grep --color=auto x &>/dev/null; then
    alias grep='grep --color=auto'
fi


########## macOS OR Linux/WSL commands
if [[ $os == "macOS" ]]; then
    alias vwmod='stat -f "%OLp"'

    ########## macOS only commands
    alias fcache='sudo dscacheutil -flushcache' # flush dns
    # When Time Mahine is backing up extremely slowly, it's usually due to throttling
    alias tmnothrottle='sudo sysctl debug.lowpri_throttle_enabled=0'
    alias tmthrottle='sudo sysctl debug.lowpri_throttle_enabled=1'
else
    alias vwmod='stat --format "%a"'
fi


########## Aliasing functions
#

# setup aliases for ls, la, l
function alias_ls() {
    # set appropriate ls color flag
    if ls --color -d . &>/dev/null; then
        alias ls='ls --color=auto'
    elif ls -G -d . &>/dev/null; then
        # FreeBSD/FreeNAS/legacy macOS versions
        alias ls='ls -G'
    fi

    alias la='ls -Ahl'
    alias ll='ls -ahl' # don't hide . and .. as above does

    # set appropriate l alias (hide owner/group if possible)
    if ls -dgo . &>/dev/null; then
        alias l='la -go'
    else
        # busybox ls
        alias l='la -g'
    fi
}
alias_ls
unset alias_ls # avoid pollution

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

    # if no combinations work, it's not installed so define our own function
    # shellcheck disable=SC2086 # flag variable needs to be unquoted
    if [[ "$($utility $exists_flag "/dev" 2>&1)" != "/dev" ]]; then
        function _basherk_realpath() {
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


########## Other hoisted functions
#

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
        [[ $positional == "$element" ]] && return 0
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

}

if exists wslpath; then
    define_wsl_commands
fi
unset define_wsl_commands # avoid pollution

# hoisted for use in cd()
function iTermSH() {
    [[ $TERM_PROGRAM != *iTerm* ]] && return

    # Help iTerm2 Semantic History by echoing current dir
    d=$'\e]1337;CurrentDir='
    d+=$(pwd)
    d+=$'\007'

    echo "$d"
}


#################### Main functions ####################


function cd() {
    local new_dir="$1"

    # go home if directory not specified
    [[ -z $new_dir ]] && new_dir=~

    # escape cd to avoid calling itself or other alias, return exit status on failure
    command cd "$new_dir" || return $?

    # echo dir for iTerm2 Semantic History immediately after cd
    iTermSH

    # print working directory, and list contents (without owner/group)
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
    if [[ $os == "macOS" ]]; then
        alias _stat_inode='stat -f%i'
    else
        alias _stat_inode='stat -c%i'
    fi

    [[ $(_stat_inode "$1") == $(_stat_inode "$2") ]] && echo "${ORANGE}Paths point to the same file (matching inode)${D}"

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

    local count debug hl matches path sudo tool
    local location="$1"
    local search="$2"

    [[ $3 =~ -(d|-debug) ]] && debug=true || sudo="$3"

    # escape all periods (regex wildcards), strip leading/trailing bash wildcards,
    # and convert all other bash wildcards to regex
    # ideally, we would also prepend a negative lookahead for / to ensure hlp
    # only highlights matches in the basename, but macos grep doesn't support it
    hl="$(sed -e 's/\./\\./g' -e 's/^*//' -e 's/*$//' -e 's/*/.*/g' <<< "$2")"

    [[ $debug ]] && echo "${CYAN}highlighting with '$hl'${D}"

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

        [[ -e $search ]] && echo "${ORANGE}Warning: if you specified a wildcard (*), bash interpreted it as globbing${D}"

        # add wildcards to file search if the user hasn't specified one
        [[ ! $search == *'*'* ]] && search="*$search*"

        echo "searching dirs in ${CYAN}\$PATH${D} for files matching ${CYAN}$search${D} (case insensitive)"

        local IFS=":"
        for path in $PATH; do
            # ignore non-existent directories in $PATH
            [[ ! -d $path ]] && continue

            [[ $debug ]] && echo "${CYAN}$sudo find \"$path\" -maxdepth 1 -iname \"$search\" | hlp -i \"$hl\"${D}"
            $sudo find "$path" -maxdepth 1 -iname "$search" | hlp -i "$hl"
        done

    elif [[ $location == "in" ]]; then
        # search file contents

        if [[ $tool != "grep" ]]; then
            echo "searching ${CYAN}$(pwf)/${D} for '${CYAN}$search${D}' (using $tool)"

            [[ $debug ]] && echo "${CYAN}$tool -C 2 \"$search\"${D}"
            $tool -C 2 "$search"
        else
            echo "searching ${CYAN}$(pwf)/${D} for '${CYAN}$search${D}' (using $tool, ignores: case, binaries, .git/, vendor/)"

            [[ $debug ]] && {
                echo "${CYAN}$tool --color=always -C 2 -Iinr \"$search\" . --exclude-dir=\".git\" --exclude-dir=\"vendor\"${D}"
                echo "${CYAN}count=\$([ABOVE COMMAND] | tee /dev/tty | wc -l) matches${D}"
            }

            # force color=always as piping to tee breaks the auto detection
            count=$($tool --color=always -C 2 -Iinr "$search" . --exclude-dir=".git" --exclude-dir="vendor" | tee /dev/tty | wc -l)

            echo "$count matches"
        fi

    elif [[ $location == "commit" ]]; then
        # find a commit with message matching string

        echo "searching commits in ${CYAN}$(git_repo_name) repo${D} for messages matching ${CYAN}$search${D} (case insensitive)"

        [[ $debug ]] && echo "${CYAN}graphall --all --grep=\"$search\" -i${D}"
        graphall --all --grep="$search" -i

    elif [[ $location == patch* ]]; then
        # find a patch containing change matching string/regexp

        echo "searching commits in ${CYAN}$(git_repo_name) repo${D} for patches matching ${CYAN}$search${D} (case sensitive)"

        [[ $location == "patchfull" ]] && local context="--function-context"

        [[ $debug ]] && {
            echo "${CYAN}for commit in $(git log --pretty=format:\"%h\" -G \"$search\"); do"
            echo "    git log -1 \"$commit\" --format=\"[...]\""
            echo "    git grep --color=always -n $context \"$search\" \"$commit\""
            echo "done${D} (simplified)"

        }

        for commit in $(git log --pretty=format:"%h" -G "$search"); do
            echo
            git log -1 "$commit" --format="%Cgreen%h %Cblue<%an> %Creset%<(52,trunc)%s %C(bold blue)%<(20,trunc)%cr%Creset %C(yellow)%d"

            # git grep the commit for the search, remove hash from each line as we echo it pretty above
            matches=$(git grep --color=always -n $context "$search" "$commit")
            echo "${matches//$commit:/}"
        done

        # display tip for patchfull
        [[ $location == "patch" ]] && echo -e "\n${GREEN}f ${*/patch/patchfull}${D} to show context (containing function)"

    elif [[ -d $location ]]; then
        # find files within a folder

        [[ -e $search ]] && echo "${ORANGE}Warning: if you specified a wildcard (*), bash interpreted it as globbing${D}"

        # add wildcards to file search if the user hasn't specified one
        [[ ! $search == *'*'* ]] && search="*$search*"

        echo "searching ${CYAN}$(command cd "$location" && pwd)${D} for files matching ${CYAN}$search${D} (case insensitive)"

        [[ $debug ]] && echo "${CYAN}$sudo find \"$location\" -iname \"$search\" | sed -e 's/^\.\///' | hlp -i \"$hl\"${D}"

        # capture find errors in global var basherk_f_errors
        # https://stackoverflow.com/a/56577569
        {
            basherk_f_errors="$( {
                # find files matching case-ins. search, strip leading ./ and highlight
                $sudo find "$location" -iname "$search" | sed -e 's/^\.\///' | hlp -i "$hl"
            } 2>&1 1>&3 3>&- )"
        } 3>&1

        # tell user if there are hidden errors
        [[ -n $basherk_f_errors ]] && \
            echo "${CYAN}$(echo "$basherk_f_errors" | wc -l | awk '{print $1}')${D} find errors hidden (${CYAN}echo \"\$basherk_f_errors\"${D})"

    elif [[ -f $location ]]; then
        # find a string within a single file

        echo "searching ${CYAN}$location${D} contents for '${CYAN}$search${D}' (using $tool)"

        [[ $debug ]] && echo "${CYAN}$tool \"$search\" \"$location\"${D}"
        $tool "$search" "$location"
    fi
}

function get_repo_url() {
    local url
    url=$(git remote get-url origin)

    # reformat url from ssh to https if necessary
    [[ $url != http* ]] && url=$(echo "$url" | perl -pe 's/:/\//g;' -e 's/^git@/https:\/\//i;' -e 's/\.git$//i;')

    echo "$url"
}

function gitinfo() {
    local repourl
    local stashcount
    local unset_variables=()

    [[ -z "$(git config user.name)" ]] && unset_variables+=("name")
    [[ -z "$(git config user.email)" ]] && unset_variables+=("email")

    # show 10 latest commits across all branches
    graphall -10

    # show total number of commits
    totalcommits

    repourl=$(get_repo_url)

    if [[ -n "$repourl" ]]; then
        echo "Repo URL: ${GREEN}$repourl${D}"
    fi

    if [[ ${#unset_variables[@]} -ne 0 ]]; then
        echo "Unset git parameters: ${PINK}$(array_join "," "${unset_variables[@]}")${D}"
    fi

    gitstats

    stashcount=$(stashes | wc -l | tr -d ' ')
    [[ $stashcount != 0 ]] && echo -e "\nYou have ${CYAN}$stashcount${D} stashes"

    echo

    git status
}

function gitstats() {
    # variables are titlecased to support bash version <4.0 lacking case manipulation
    # shellcheck disable=SC2034 # dynamic variables
    local Changed='git diff' Staged='git diff --staged'

    for command in Staged Changed; do
        if [[ -n "$(${!command} --stat)" ]]; then
            echo
            echo "$command:"
            # run command again instead of capturing output above to preserve colour and stat output width
            ${!command} --stat
        fi
    done
}

function h() {
    [[ -z $1 ]] && history && return

    history | grep "$@"
}

# _have and have are required by some bash_completion scripts
if ! exists _have; then
    # This function checks whether we have a given program on the system.
    _have() {
        PATH=$PATH:/usr/sbin:/sbin:/usr/local/sbin type "$1" &>/dev/null
    }
fi
if ! exists have; then
    # Backwards compatibility redirect to _have
    have() {
        unset -v have
        # shellcheck disable=SC2034 # ignore "have appears unused" this is for compatibility
        _have "$1" && have=yes
    }
fi

# Highlight Pattern
# Works like grep but shows all lines
function hlp() {
    local arg
    local flags
    local regex

    if [[ -z $1 ]] || [[ $1 == "--help" ]]; then
        echo "hlp - highlight pattern:"
        echo "  highlight a string or regex pattern from stdin"
        echo "  see grep for more options"
        echo
        echo "usage: <command> | hlp [options...] [pattern]"
        echo "  options:"
        echo "    -i            case-insensitive matching"
        echo
        echo "  patterns:"
        echo "    foo bar           match either 'foo' or 'bar'"
        echo "    'foo bar'         match 'foo bar'"
        echo "    '\\\$foo bar'       match '\$foo bar'"
        echo "    '[0-9]{1,3}'      match 000 through 999"
        return
    elif [[ $1 == "-i" ]]; then
        shift
        flags="-iE"
    else
        flags="-E"
    fi

    # always grep for $ (end of line) to show all lines, by highlighting the newline character
    regex="$"

    # concatenate arguments with logical OR
    for arg in "$@"; do
        regex+="|$arg"
    done

    grep $flags "$regex"
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

    # allow scanning local subnet with sudo without explitly passing ip
    [[ $ip == "sudo" ]] && unset ip && sudo="sudo"

    [[ -z $ip ]] && {
        # scan subnet using local ip address with /24 subnet mask
        ip="$(ifconfig | sed -En 's/127.0.0.1//; s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p;' | head -1)/24"
    }

    # if only subnet was given, build a complete address
    local re='^[0-9]{1,3}$'
    [[ $ip =~ $re ]] && ip="192.168.$ip.1/24"

    echo "$sudo scanning ${CYAN}$ip${D}"
    $sudo nmap -sn -PE "$ip"
    # shsellcheck disable=SC2086 # sudo needs to be unquoted
    echo $sudo nmap -sn -PE "$ip"
}

function lastmod() {
    if [[ $os == "macOS" ]]; then
        echo "Last modified" $(( $(date +%s) - $(stat -f%c "$1") )) "seconds ago"
    else
        echo "Last modified" $(( $(date +%s) - $(date +%s -r "$1") )) "seconds ago"
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
    new_location=$(echo "$new_location" | head -n1 | tr -d "\"‘’'")
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
    echo "$notification"
}

function osver() {
    if [[ $os == "macOS" ]]; then
        sw_vers
    else
        cat /etc/*-release
    fi
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
        echo "Search manual or --help for command & arguments"
        echo "  Accepts options/text without requiring escaping"
        echo "  Actual rtfm options are prepended with --rtfm-"
        echo
        echo "Usage: rtfm <command> [options...] [arguments...] [raw text...] [--rtfm-options...]"
        echo "  options:"
        echo "    --help            show this page"
        echo "    --rtfm-#          show # lines of context after match (0-9, default: 2)"
        echo "    --rtfm-debug      show debugging info"
        echo "    --rtfm-strict     ignore options scattered through descriptions of other options by explicitly matching start of line"
        return
    }

    local -a long_opts
    local -a raw
    local context=2
    local debug
    local opts
    local regex
    local rtfm_opt
    local strict_mode

    # extract command from argument list
    local command_name="$1"
    shift

    # loop through arguments
    while (( $# > 0 )); do
        case "$1" in
            --rtfm-*)
                # strip prepended --rtfm-
                rtfm_opt="${1:7:99}"

                if [[ $rtfm_opt =~ [0-9] ]]; then
                    context=$rtfm_opt
                elif [[ $rtfm_opt == "debug" ]]; then
                    debug=true
                elif [[ $rtfm_opt == "strict" ]]; then
                    strict_mode=true
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

    [[ $debug ]] && echo "${CYAN}rtfm is case-sensitive${D}"

    if [[ $strict_mode ]]; then
        [[ $debug ]] && echo "${CYAN}Strict mode: ignore options scattered through descriptions of other options${D}"
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

    if ! man "$command_name" >/dev/null 2>&1; then
        [[ $debug ]] && {
            echo "No man found for $command_name"
            echo "\"$command_name\" --help | grep -E \"$regex\""
        }

        "$command_name" --help | grep -E "$regex"
        return
    fi

    # open manual if no search specified
    [[ -z $regex ]] && {
        man "$command_name"
        return
    }

    # pipe man through col to fix backspaces and tabs, and grep the output for our regex
    [[ $debug ]] && echo "man \"$command_name\" | col -bx | grep -E -A \"$context\" -e \"$regex\""
    man "$command_name" | col -bx | grep -E -A "$context" -e "$regex"
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
        echo "$file"
        ssh-keygen -E md5 -lf "$file" 2>/dev/null && \
        ssh-keygen -E sha256 -lf "$file" 2>/dev/null && \
        echo
    done
}

function _source_bash_completions() {
    [[ $1 == "--help" ]] && {
        echo "Source all completion files from valid paths"
        echo "Usage:"
        echo "    _source_bash_completions [options]"
        echo "        --help               Show this screen"
        echo "        -f, --force          Don't skip paths containing >250 files"
        return
    }

    local -a absolutes paths
    local absolute_path file filecount limit=250 path

    [[ $1 =~ -(f|-force) ]] && limit=10000

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

    for path in "${absolutes[@]}"; do
        # shellcheck disable=SC2012 # ls (over find) is adequate for a quick file count
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
    local default_key i inherit keys_found output
    local key="$1"
    local list_keys=true

    if [[ -n $key ]]; then
        # standardise user specified key or ~/.ssh/key to absolute pathname
        for i in $key ~/.ssh/$key; do
            # shellcheck disable=SC2086 # key path needs to be unquoted
            [[ -f $i ]] && key="$(_realpath $i)" && break
        done
    else
        # set a default key if none specified, in order of preference
        for i in ed25519 rsa dsa ecdsa; do
            [[ -f ~/.ssh/id_$i ]] && default_key="$(_realpath ~/.ssh/id_$i)" && break
        done
    fi

    if exists keychain; then
        # tell keychain to inherit forwarded or pre-existing local agent, but
        # only if it contains "agent"; we ignore the builtin macOS agent, and
        # spawn a new, keychain-compatible agent which persists between shells
        if [[ $SSH_AUTH_SOCK == *agent* ]]; then
            inherit="--inherit any"
        fi

        # add a default key, if there is one
        # we do this so that keychain always adds a key, and we can do this because
        # keychain doesn't add keys again if they're already loaded, unlike ssh-add
        [[ -z $key && -n $default_key ]] && key="$default_key"

        # shellcheck disable=SC2086 # params need to be unquoted
        eval "$(keychain --eval $inherit $key)"

        keychain -l
    else
        output="keychain not available, "

        if [[ -z $SSH_AUTH_SOCK ]]; then
            keys_found="$(find ~/.ssh -type f \( -iname "*id*" ! -iname "*.pub" \) -print -quit 2>/dev/null)"

            # only start ssh-agent if the user specified a key, or if ~/.ssh contains a key
            if [[ -n $keys_found || -n $key ]]; then
                output+="spawning new ssh-agent"
                eval "$(ssh-agent -s)"
            else
                output+="no keys found, not spawning ssh-agent"
                list_keys=false
            fi
        else
            output+="using forwarded ssh-agent"
        fi

        # add a default key, but only if the user hasn't specified one, we find a default, and no keys are loaded
        if [[ -z $key && -n $default_key && "$(ssh-add -ql 2>/dev/null)" == "The agent has no identities." ]]; then
            key=$default_key
        fi

        # shellcheck disable=SC2086 # key needs to be unquoted
        [[ -n $key ]] && ssh-add $key

        echo -e "$output\n"

        [[ -n $key || $list_keys == true ]] && ssh-add -l
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

function suho() {
    if [[ $os == "macOS" ]]; then
        sudo sublime /etc/hosts
    elif [[ $os == "Windows" ]]; then
        sudo vi /mnt/c/Windows/System32/drivers/etc/hosts
    fi
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

    # grep process list (and PID to show header), without matching itself
    # shellcheck disable=SC2009 # prefer grep over pgrep
    ps -aef | grep -Ev "grep.*PID" | grep -E "PID|$processes"
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
    local ref
    local -i commits

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

    echo "${D}Commits for ${CYAN}$(git_repo_name)${D} starting $ref ($override): ${CYAN}$commits${D}"
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

    if rsync -az "$src" "$dest":~/.basherk; then
        echo "$dest updated with $(basherk --version)"
    else
        echo "${RED}basherk update failed for $dest${D}"
    fi
}

function vollist() {
    # handle voldisplay --help => vollist -a --help
    if [[ $1 == "--help" || $2 == "--help" ]]; then
        echo "vollist"
        echo "  display summary or extended info for volumes and volume groups"
        echo "  wraps pvs/vgs/lvs (and *display), run as sudo"
        echo
        echo "usage: vollist [options]"
        echo "  options:"
        echo "    -a            show all/extended information"
        return
    fi

    local selection
    local command
    local extended=(pvdisplay vgdisplay lvdisplay)
    local summary=(pvs vgs lvs)

    if [[ $1 == "-a" ]]; then
        selection=("${extended[@]}")
    else
        selection=("${summary[@]}")
    fi

    for command in "${selection[@]}"; do
        echo
        echo "${CYAN}$command${D}"

        # shellcheck disable=SC2086 # leave $command unquoted
        sudo $command
    done
}

if exists pvs; then
    alias voldisplay='vollist -a'
else
    unset vollist
fi

# extend information provided by which
function which() {
    local app="$1"
    local location

    location=$(command which "$app")

    echo "$location" # lol, i'm a bat

    # check if which returns anything, otherwise we just ls the current dir
    [[ -n $location ]] && ls -ahl "$location"
}

# return working directory with gitroot path replaced with repo name (if necessary)
# ~/dev/repos/basherk/test => basherk repo/test
function echo_working_dir() {
    local dir="$1"
    local gitrepo subfolder

    if ! exists git; then
        # return input if git is not installed
        echo "$1"
        return 0
    fi

    gitrepo=$(git_repo_name 2>/dev/null) || {
        # return input if not in a git repo
        echo "$1"
        return
    }

    subfolder=$(git rev-parse --show-prefix)

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
    local gitrepo gitroot

    gitroot=$(git_root) || return # return if not in a git repo

    gitrepo=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///; s/\.git//;')

    # return git root folder name if git remote is blank
    [[ -z $gitrepo ]] && gitrepo="${gitroot##*/}"

    echo "$gitrepo"
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

    # shellcheck disable=SC2016
    # working dir or repo name substitute
    prompt+='${D}in ${GREEN}$(echo_working_dir "\w") '

    # shellcheck disable=SC2016
    if exists git; then prompt+='${D}$(git_in_repo) ${PINK}$(git_branch)${GREEN}$(git_dirty) '; fi

    # shellcheck disable=SC2016
    # manually set mark to align it with the prompt, ensure it doesn't break (e.g. after re-sourcing basherk)
    [[ $TERM_PROGRAM == *iTerm* ]] && prompt+='${D}\n\[$(iterm2_prompt_mark)\]$ ' || prompt+='${D}\n$ '
fi

export PS1=$prompt
unset prompt

# Set window title to something readable
set_title
export DISABLE_AUTO_TITLE="true"

# source post-basherk definitions
[[ -f "$basherk_dir/post-basherk.sh" ]] && . "$basherk_dir/post-basherk.sh"

# run sshl last to avoid terminating basherk when cancelling ssh passkey prompt
# don't run sshl if ssh isn't installed, or if we're re-sourcing basherk
if ! exists ssh-add; then return; fi
[[ -z $basherk_re_sourcing ]] && sshl
