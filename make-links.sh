#!/bin/bash

SRC=$(dirname $0)

ln -s $SRC/configs/.zshrc $HOME
ln -s $SRC/configs/.zshenv $HOME
ln -s $SRC/configs/.zshenv $HOME
ln -s $SRC/configs/.gitattributes $HOME
ln -s $SRC/configs/.hgrc $HOME
ln -s $SRC/configs/.vimrc $HOME
ln -s $SRC/configs/.emacs.d $HOME

ln -s $SRC/configs/.oh-my-zsh/custom $HOME/.oh-my-zsh
ln -s $SRC/configs/.config/nvim $HOME/.config
ln -s $SRC/configs/.config/tmux $HOME/.config
ln -s $SRC/configs/.config/jj $HOME/.config
ln -s $SRC/configs/.config/zed $HOME/.config
