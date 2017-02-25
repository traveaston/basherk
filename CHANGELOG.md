# Basherk Change Log

## Version [124] - 2017-02-25
#### Added
- Add wrapper to translate `yum` commands to `apt-get` family of functions on windows bash
- Add wrapper to scan IP and subnet with `nmap`
- Ignore `test` and `time` in bash history

#### Fixed
- Fix bugs relating to `sshl` and `keychain`
- Fix `exists` command not found error

#### Removed
- Unused functions: `pdtemp`, `socksproxy` other aliases
- `nevermind` command now only advises what to do and warns what happens when used, instead of performing the command


## Version [123] - 2017-02-23
#### Added
- Add function to set window title
- Add `gitwelcome` command for info about current repo
- Add long version flag

#### Changed
- `now` shows date in more readable format
- Rename `pdsearch` command to `searchcontents`

#### Fixed
- RSA insecurity warning was too long

#### Removed
- Unused change dir and git commands


## Version [122] - 2017-02-20
#### Added
- Add `commit` function. Counts characters, performs spell check, and confirms commit message all in one.
- Add `stage` alias to patch changes into staging area
- Add `attach` alias for tmux (if installed)
- Add `discardpatch` alias to discard parts of a file

#### Changed
- Alias `la` no longer shows group on linux

#### Fixed
- Illegal operation error for `rmdir`

#### Removed
- `apache_wr` function


## Version [121] - 2017-01-20
#### Fixed
- Check existence before sourcing git completion


## Version [120] - 2016-12-01
#### Initiate version control

[124]: https://bitbucket.org/czechmeight/basherk/branches/compare/124%0D123
[123]: https://bitbucket.org/czechmeight/basherk/branches/compare/123%0D122
[122]: https://bitbucket.org/czechmeight/basherk/branches/compare/122%0D121
[121]: https://bitbucket.org/czechmeight/basherk/branches/compare/121%0D120
[120]: https://bitbucket.org/czechmeight/basherk/commits/8f7b0f2a4b4a55240320e4437928b5ccab4e1640
