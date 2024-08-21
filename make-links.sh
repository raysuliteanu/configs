#!/bin/bash -x
# Gets the directory of the current script
SCRIPT_DIR=$(cd "$(dirname "${(%):-%x}")"; pwd)

# files
ln -s $SCRIPT_DIR/.zshrc $HOME
ln -s $SCRIPT_DIR/.zshenv $HOME
ln -s $SCRIPT_DIR/.zshenv $HOME
ln -s $SCRIPT_DIR/.gitconfig $HOME
ln -s $SCRIPT_DIR/.gitattributes $HOME
ln -s $SCRIPT_DIR/.hgrc $HOME
ln -s $SCRIPT_DIR/.vimrc $HOME

# directories
ln -s $SCRIPT_DIR/.emacs.d $HOME
ln -s $SCRIPT_DIR/.oh-my-zsh/custom $HOME/.oh-my-zsh
ln -s $SCRIPT_DIR/.config/nvim $HOME/.config
ln -s $SCRIPT_DIR/.config/tmux $HOME/.config
ln -s $SCRIPT_DIR/.config/jj $HOME/.config
ln -s $SCRIPT_DIR/.config/zed $HOME/.config
ln -s $SCRIPT_DIR/.config/bpytop $HOME/.config
