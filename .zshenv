#!/bin/sh
if [ -n "$TMUX" ]; then
  export TERM=screen-256color
fi

. "$HOME/.cargo/env"

export PAGER='less'
export EDITOR=vi
export BAT_THEME=GitHub
