# pre-basherk
# Things to define before basherk runs

# fix for mail before anything else
[[ $HOSTNAME != *"mail"* ]] && shopt -s nocasematch
