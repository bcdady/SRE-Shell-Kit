---
layout: default
permalink: /README/
title: "What's this about?"
---

# SRE Toolkit / SRE Shell-kit

This SRE Toolkit is intended to help Site Reliability Engineers (SRE) to quickly and consistently get essential tools setup for use. (Other Software Engineers such as SDE/SWE/SDET may also find this useful). As Automation (as a pillar of reducing toil) is a key tenet of SRE, then naturally, getting an SRE prepared to be productive (whether a new team member getting setup, or an established team member (re)loading up a new laptop) should indeed be automated and repeatable.

## More backstory

Such is the goal of SRE Toolkit. The (repository) name was/is SRE Shell Kit, as the bedrock component of any SRE Toolkit is a ready-to-run command line shell (or terminal, or console, or whatever you prefer to label it). The essential means of a human getting a computer to efficiently doing designated, desired work, (especially across a cloud-scale technology stack) is through a keyboard specifying instructions at the command-line. Customizing the command-line operating environment to reduce toil is a natural extension of this human - computer interface.

## Getting Started

### POSIX

POSIX is a standard acronym for the Portable Operating System Interface.
In current variations of sh, bash, ksh there is negligible difference between 

Or
* A Unix-like operating system: macOS, Linux, BSD. On Windows: WSL is preferred, but cygwin or msys also mostly work.
* [Zsh](https://www.zsh.org) should be installed (v4.3.9 or more recent). If not pre-installed (run `zsh --version` to confirm), check the following instructions here: [Installing ZSH](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
* `curl` or `wget` should be installed
* `git` should be installed

### Basic Installation

Oh My Zsh is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`.

#### via curl

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### via wget

```shell
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Manual inspection

It's a good idea to inspect the install script from projects you don't yet know. You can do
that by downloading the install script first, looking through it so everything looks normal,
then running it:

```shell
curl -Lo install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh install.sh
```

## Using SRE toolkit


## Help improve this SRE toolkit

See something you think could be done better? Feel free to fork the project and/or submit a pull request.

We welcome your improvements.
