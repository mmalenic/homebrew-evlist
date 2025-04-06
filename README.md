# Homebrew tap for evlist

This repository contains the Homebrew tap for evlist. View documentation at the [main] repository.

## Install evlist

Install evlist by tapping this repository:

```sh
brew tap mmalenic/evlist && brew install evlist
```

## Build the formula from the repo

Build the formula locally from the repo using:

```sh
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --verbose --debug ./evlist.rb
```

## Pull request automation

To update the package, create a pull request bumping the url and sha256 (e.g. using `brew bump-formula-pr`). 
Once checks have passed, label the pull request with `pr-pull`, which should upload bottles to the GitHub container
registry and merge the pull request.

[main]: https://github.com/mmalenic/evlist