---
layout: default
permalink: /README/
title: "What's this about?"
---

# SRE Toolkit / SRE Shell-kit

This SRE Toolkit is intended to help Site Reliability Engineers (SRE), or Software Engineers (SDE/SWE) to quickly and consistently get essential tools setup for use. As Automation (as a pillar of reducing toil) is a key tenet of SRE, then naturally, getting an SRE (whether a new team member getting their kit setup, or an established team member loading up a new laptop) should indeed be automated / orchestrated.

## More backstory

Such is the goal of SRE Toolkit. The (repository) name was/is SRE Shell Kit, as the bedrock component of any SRE Toolkit is a ready-to-run command line shell (or terminal, or console, or whatever you prefer to label it). The essential means of a human getting a computer to efficiently doing designated, desired work, (especially across a cloud-scale technology stack) is through a keyboard specifying instructions at the command-line. Customizing the command-line operating environment to reduce toil is a natural extension of this human - computer interface.

{: .getting-started}

## Getting Started

### POSIX

POSIX is a standard acronym for the Portable Operating System Interface.
In 2020 (and beyond), there is negligible difference

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

## Not comprehensive

This site is not a comprehensive directory of open source licenses. The vast majority of projects will likely be well served by one of the three options highlighted on the [homepage](/) — choosing the license [preferred](/community/) by projects similar to yours, or the most popular permissive license ([MIT](/licenses/mit/)), or the most popular copyleft license ([GNU GPLv3](/licenses/gpl-3.0/)). Just in case you have specific needs not covered by these, we also highlight a [few other licenses to consider](/licenses/) and have a page about [licenses for non-software projects](/non-software/).

See our [appendix](/appendix/) for a table of every license cataloged in the [choosealicense.com repository](https://github.com/github/choosealicense.com) and the links below for *even more* licenses that you **do not** need to learn about to still choose a great license for your project.

### Additional resources

{: .bullets}

* Open Source Initiative's FAQ on [Which Open Source license should I choose to release my software under?](https://opensource.org/faq#which-license)
* Free Software Foundation's [advice on how to choose a license](https://www.gnu.org/licenses/license-recommendations.html)
* [Joinup Licensing Assistant](https://joinup.ec.europa.eu/collection/eupl/joinup-licensing-assistant-jla), an interactive license chooser from the European Commission
* [The Legal Side of Open Source](https://opensource.guide/legal/), an Open Source Guide covering licensing and related issues

## Help improve this SRE toolkit

Choosealicense.com isn't just about open source; the site itself is open source as well. See something you think could be done better? Feel free to [fork the project](https://github.com/github/choosealicense.com) on GitHub and submit a pull request. We welcome your improvements.

