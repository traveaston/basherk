# pre-basherk
# © Trav Easton 2016

export HOMEBREW_GITHUB_API_TOKEN="a7b95e6f3d32667199ed99e753345d0c7c4af33a"

# fix for mail before anything else
[[ $host != *"mail"* ]] && shopt -s nocasematch || host="mail"
