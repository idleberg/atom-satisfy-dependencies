# satisfy-dependencies

[![apm](https://flat.badgen.net/apm/license/satisfy-dependencies)](https://atom.io/packages/satisfy-dependencies)
[![apm](https://flat.badgen.net/apm/v/satisfy-dependencies)](https://atom.io/packages/satisfy-dependencies)
[![apm](https://flat.badgen.net/apm/dl/satisfy-dependencies)](https://atom.io/packages/satisfy-dependencies)
[![CircleCI](https://flat.badgen.net/circleci/github/idleberg/atom-satisfy-dependencies)](https://circleci.com/gh/idleberg/atom-satisfy-dependencies)
[![David](https://flat.badgen.net/david/dep/idleberg/atom-satisfy-dependencies)](https://david-dm.org/idleberg/atom-language-nsis)

Satisfies Atom [package dependencies](https://www.npmjs.com/package/atom-package-dependencies) and, optionally, Node dependencies of installed packages

## Installation

### apm

Install `satisfy-dependencies` from Atom's [Package Manager](http://flight-manual.atom.io/using-atom/sections/atom-packages/) or the command-line equivalent:

`$ apm install satisfy-dependencies`

**Note:** Installation might take a bit longer than what you're used to, building binaries takes its time

### Using Git

Change to your Atom packages directory:

```bash
# Windows
$ cd %USERPROFILE%\.atom\packages

# Linux & macOS
$ cd ~/.atom/packages/
```

Clone the repository as `satisfy-dependencies`:

```bash
$ git clone https://github.com/idleberg/atom-satisfy-dependencies satisfy-dependencies
```

## Usage

Run any of the following commands from the [Command Palette](https://atom.io/docs/latest/getting-started-atom-basics#command-palette):

* `Satisfy Dependencies: All`
* `Satisfy Dependencies: Atom Packages`
* `Satisfy Dependencies: Node Packages`

**Note:** In the package settings you specify your preferred package manager to install Node dependencies.

## License

This work is licensed under the [The MIT License](LICENSE.md).
