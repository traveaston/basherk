# basherk

[![ShellCheck](https://github.com/traveaston/basherk/actions/workflows/action.yaml/badge.svg)](https://github.com/traveaston/basherk/actions/workflows/action.yaml)

(Pronounced sort of how bashrc sounds phonetically)  
Handy aliases and functions to make your life in the terminal easier. Essentially:  
![alt text](https://imgs.xkcd.com/comics/automation.png "xkcd: Automation")

### Installing

The easiest way to start using basherk is to download and source the file  
`curl https://raw.githubusercontent.com/traveaston/basherk/master/basherk.sh -o ~/.basherk && . ~/.basherk`

To source it each session automatically  
`echo -e "\n. ~/.basherk # source basherk\n" >> ~/.bashrc`

To have root source basherk from the same file  
`sudo echo -e "\n. $(_realpath ~/.basherk) # source basherk\n" >> /root/.bashrc`

___

Additionally, you can clone the repo for contributing, custom aliases, etc.

Clone the repo to wherever you would like to store it  
`git clone https://github.com/traveaston/basherk.git`

Source it this session  
`source basherk/basherk.sh`

Then either symlink basherk into your home folder and source it from there  
```
ln -s "$(_realpath basherk/basherk.sh)" ~/.basherk
echo -e "\n. ~/.basherk # source basherk\n" >> ~/.bashrc
```

Or source it straight from the repo  
`echo -e "\n. \"$(_realpath basherk/basherk.sh)\" # source basherk\n" >> ~/.bashrc`

### Updating

If you aren't using the repo, `basherk --update` or `ubash` will download the latest revision from the master branch and re-source itself.

## Contributing

* Lint basherk with shellcheck `shellcheck -s bash basherk.sh`
* 4 space indentation
* Double quotes
  * Aliases use single quotes
  * Regexes use single quotes
  * Rare cases where single quotes make more sense
* Don't quote LHS of comparison (eg. `[[ $foo == "$bar" ]]`), except:
  * Subshells should be quoted for readability `[[ "$(cat bar.log)" == "foo" ]]`
  * Variables concatentated with strings should be quoted
* Quote RHS of comparison (eg. `[[ $foo == "$(cat bar.log)" ]]`), except:
  * Regex or pattern (and vars containing) shouldn't be quoted `[[ $os =~ (mac|unix) ]]`
  * String with wildcards shouldn't be quoted `[[ $dir == *.git* ]]`
  * String with wildcards and spaces should be half-quoted `[[ $dir == *"git bar"* ]]`
  * Integers shouldn't be quoted
* Variables for if switches (eg. `[[ -z $foo ]]`) shouldn't be quoted, except:
  * Variables concatentated with strings should be quoted
* Variable assignment should be quoted (`foo="bar"`), except:
  * When assigning subshell output, don't quote `foo=$(curl ifconfig.me)`
  * When assigning subshell + strings, quote `foo="user@$(curl ifconfig.me)"`
  * When assigning an integer, don't quote `bar=256`
  * When assigning a boolean, don't quote `bar=false`
* Simple regexes can be inline if it is clean but more complex expressions should be passed by variable
  * Also when containing special characters, especially `space`, should be passed by variable
* Headings
  * Main and subheadings are prepended with 2 lines
  * Main code blocks are surrounded with Start/End headings
  * Main headings are surrounded with 20x#
  * Subheadings are prepended with 10x#
  * Subheadings with no blank lines before next subheading are placed immediately above the code (see `Git diff aliases`)
  * Subheadings containing comments or blank lines before next subheading contain an additional newline with a single # (see `Redefine builtin commands`)
  * Aliases, functions, etc, under headings are sorted alphabetically most of the time, but not always.

## Authors

* **Trav Easton** - *Initial work & maintenance*

See also the list of [contributors](https://github.com/traveaston/basherk/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Steve Losh http://stevelosh.com/blog/2009/03/candy-colored-terminal/
* more credits peppered throughout [basherk.sh](basherk.sh)
