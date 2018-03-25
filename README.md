# basherk

(Pronounced sort of how bashrc sounds phonetically)

Handy aliases and functions to make your life in the terminal easier

Essentially:

![alt text](https://imgs.xkcd.com/comics/automation.png "xkcd: Automation")

### Installing

Ideally you want to clone the repo and symlink basherk into your home folder (to allow custom aliases, etc), and just use the main basherk file on servers you manage, but it's up to you.

Clone the repo  
`git clone https://github.com/traveaston/basherk.git`

Enter the directory and symlink basherk to the home folder
```
cd basherk/
ln -s "$(realpath basherk.sh)" ~/.basherk
```

Either add the following lines your .bashrc file to source basherk on terminal open, or run the command at the bottom to add them automatically

```
# source basherk
. ~/.basherk
```

You can also run the following command to download and run the latest version of basherk if it isn't installed already.  
`wget https://raw.githubusercontent.com/traveaston/basherk/master/basherk.sh -O ~/.basherk && . ~/.basherk`

Source basherk from .bashrc  
`echo >> ~/.bashrc && echo "# source basherk" >> ~/.bashrc && echo ". ~/.basherk" >> ~/.bashrc`

### Updating

Running `ubash` or `basherk --update` will download the latest revision from the master branch and re-source itself.

## Contributing

Indentation: 4 spaces

## Authors

* **Trav Easton** - *Initial work*

See also the list of [contributors](https://github.com/traveaston/basherk/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Steve Losh http://stevelosh.com/blog/2009/03/candy-colored-terminal/
