#!/bin/zsh
echo $0

# iTerm key bindings - https://coderwall.com/p/a8uxma/zsh-iterm2-osx-shortcuts
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh
bindkey ' ' magic-space # [Space] - do history expansion
