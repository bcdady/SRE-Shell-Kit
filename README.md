---
layout: default
permalink: /README/
title: "What's this about?"
---

# SRE Toolkit / SRE Shell-kit

This SRE Toolkit is intended to help Site Reliability Engineers (SRE) or Software Development Engineers (SDE/SWE) to quickly and consistently get essential tools setup for use, such as when working on a new Macbook or laptop. This toolkit is intended to provide a pathway from whichever Operating System a person feels most comfortable with, to an operating environment that has consistent set of DevOps / SRE tools for the person to use. It is not intended to prepare a comprehensive development environment for any particular programming language, but it very well may provide a fast-track that reduces the amount of time required to get to that point.

There's no good reason to do manually tasks that computers can do more quickly and consistently. By storing these setup scripts in a git repository, the manual initialization work is reduced to pulling the branch and running the script(s).
This helps any software engineer prepare to be productive (whether a new team member getting setup, or an established team member (re)loading up a new laptop) in an automated and repeatable manner.

## Tier 0 tool: A POSIX shell

This toolkit is intended primarily for use in a zsh and/or bash environment, but it should be possible to make it functional in any "[Mostly POSIX-compliant](https://en.wikipedia.org/wiki/POSIX#Mostly_POSIX-compliant)" shell.

POSIX is the acronym for the Portable Operating System Interface standard, upon which the most prevalent command shells have been built. In current variations of sh, bash, ksh, and zsh there is negligible difference between the built-in commands provided by the shell. bash (Bourne Again SHell) is still the de-facto shell for most common Linux distributions. In 2019, macOS Catalina adopted Zsh as the default login shell". "[Zsh](https://en.wikipedia.org/wiki/Z_shell) is an extended Bourne shell with many improvements, including some features of Bash, ksh, and tcsh". This

## Toolkit contents

### MVP: Minimum Viable Project

The tools selected for this toolkit are not necessarily superior to all others, but they sufficiently meet a need, are reasonably actively maintained (so as to not fall prey to new security vulnerabilities), and present low friction to getting setup on a new machine.

### Myriad options and alternatives

There are many tools that different software engineers have created to meet their needs over the years. As a colleague recently joked with me: "When a software developer encounters a new problem, their instinct is to develop software to solve that problem". In my experience, it is rare for a software engineer to go looking for a solution to a particular problem, and for them to find am existing option that meets their needs or expectations. From that perspective, the tools included or even recommended here are not presented as objectively the correct options. If you feel strongly that the value or efficacy of this toolkit could be improved, you are invited and encouraged to contribute such a nomination. See (Help improve this SRE toolkit)[##HelpimprovethisSREtoolkit]

### Tier 1: Homebrew

Install homebrew -- https://brew.sh/

#### On Mac

For the Homebrew install script to complete successfully on an otherwise 'factory' macOS, it needs commands provided in the xcode-select package.

```shell
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### On Linux

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Tier "1.5": zsh and Oh-My-Zsh

Install Oh-My-Zsh -- <https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH>

```shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

> In order for Oh-My-Zsh to work, Zsh must be installed.
> Please run zsh --version to confirm.
> Expected result: zsh 5.0.8 or more recent
> Additionally, Zsh should be set as your default shell.
> Please run echo $SHELL from a new terminal to confirm.
> Expected result: /usr/bin/zsh or similar

#### On Mac (Recommended)

- [Zsh](https://www.zsh.org) should be installed (v4.3.9 or more recent). If not pre-installed (run `zsh --version` to confirm), check the following instructions here: [Installing ZSH](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
- `curl` or `wget` should be installed
- `git` should be installed

#### On Linux (Optional)

[Installing ZSH and Oh-My-Zsh on Linux is optional](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH). This toolkit will fine function without it.

### Tier 2 tools

Key "formula" / packages that run in a CLI
**for each, see https://formulae.brew.sh/formula/{formula-name}**

- openssl@1.1 Note: All OpenSSL versions before 1.1.1 are out of support and no longer receiving updates.
- monkeysphere
- curl (and/or [curlie](https://curlie.io/))
- lsof
- macos-trash
  - and make alias for rm ?
- howdoi
- liquidprompt
- zsh-vi-mode
- zsh-you-should-use
- hstr
- grex
- cf
- comby
- sd
- autossh
- whois
- findomain
- subfinder
- dog
- dnstwist
- dnstracer
- ipv6calc
- silicon
- wtfutil (/usr/local/Cellar/wtfutil/0.37.0/bin/wtfutil)
- editorconfig
- git
- gitup
- onefetch
- gitversion
- commitizen
- git-flow
- git-standup
- git-sizer
- gitleaks
- gh
- glow
- glab
- lab
- autoenv or direnv or ... ?
- envchain
- docker
- crane
- hadolint / dockle
- docker-clean
- docker-slim
- grype
- dependency-check
- shellcheck
- shfmt
- bazel
- buildifier (https://github.com/bazelbuild/buildtools#readme)
- bazelisk
- earthly
- awscli
- aws-rotate-key
- aws-shell
- aws-console
- awsume
- awscurl
- cli53
- certigo
- chamber
- aws-okta (or gimme-aws-creds ?)
- aws-google-auth
- jq
- jid
- jc (or jo or jshon ?)
- gron
- yq
- shyaml
- yamllint
- jsonlint
- Task (TaskWarrior, tasksh ?)
- go-task (Taskfile)
- go-jira
- prettier
- python3
- pipenv
- terraform
- terraformer / terraforming ?
- iam-policy-json-to-terraform
- terraform_landscape
- terraform-docs
- infracost
- inframap
- terrascan
- tfenv
- tflint
- tfsec
- checkov
- packer
- kubernetes-cli (kubectl)
- kubie (instead of kubectx/kubens)
- clusterctl
- click
- kubergrunt
- kubeaudit
- sonobuoy
- kubespy
- krew
- helm
- helmfile
- kube-linter
- chart-testing
- stern
- helmsman
- nuclei
- devspace
- mkdocs
- weaveworks/tap/eksctl
- teleport
- testssl
- tmux
- tmux-xpanes

### Tier 3

- go (lang)

```shell
brew install awscli git go ktail  kubernetes-cli tmux tmux-xpanes insomnia maccy meld powershell qlimagesize qlmarkdown quicklook-json
```

### Other ("Cask") Apps

A "cask" is a "Homebrew package definition that installs macOS native applications" -- [Terminology](https://docs.brew.sh/Manpage#terminology)

brew install --cask iterm2 firefox microsoft-edge visual-studio-code

brew install --cask appcleaner authy cyberduck discord rectangle lens maccy keybase spotify sunsama superhuman owasp-zap

# ansible

# aws-iam-authenticator

# bandwhich bat

# docker

# helm

# jq

# Lens

# python@3.8 python@3.9

# redis-cli terraform tfswitch

## Getting Started with Oh My ZSH

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

### GitLab API scripts

See [./gitlab/README.md](./gitlab/README.md)

**Not comprehensive**

## More backstory

The bedrock (as in, under the foundation) component of any software engineer toolkit is a ready-to-run [command line shell](https://en.wikipedia.org/wiki/Comparison_of_command_shells) (or terminal, or console, or whatever you prefer to label it). The essential means of a human getting a computer to perform designated work, (especially across a cloud-scale technology stack) is through specifying instructions at a command-line with a keyboard (not a mouse :) ). Customizing and optimizing the command-line operating environment to reduce toil is a fundamental function of enabling this human - computer interface to be efficient.

## Help improve this SRE toolkit

See something you think could be done better? Feel free to fork the project and/or submit a pull request.

We welcome your improvements.
