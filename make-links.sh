#!/bin/bash
LN=ln
MD=mkdir

# no-op the linking if executed with -x option
if [[ "$-" == *x* ]]; then
    LN="echo ln"
    MD="echo mkdir"
fi

# Gets the directory of the current script
SCRIPT_DIR=$(cd "$(dirname "${(%):-%x}")"; pwd)

# files
${LN} -s $SCRIPT_DIR/.zshrc $HOME
${LN} -s $SCRIPT_DIR/.zshenv $HOME
${LN} -s $SCRIPT_DIR/.zshenv $HOME
${LN} -s $SCRIPT_DIR/.gitconfig $HOME
${LN} -s $SCRIPT_DIR/.gitattributes $HOME
${LN} -s $SCRIPT_DIR/.hgrc $HOME
${LN} -s $SCRIPT_DIR/.vimrc $HOME
${LN} -s $SCRIPT_DIR/.wezterm.lua $HOME

# directories
${LN} -s $SCRIPT_DIR/.emacs.d $HOME
${LN} -s $SCRIPT_DIR/.oh-my-zsh/custom $HOME/.oh-my-zsh
${LN} -s $SCRIPT_DIR/.config/nvim $HOME/.config
${LN} -s $SCRIPT_DIR/.config/tmux $HOME/.config
${LN} -s $SCRIPT_DIR/.config/jj $HOME/.config
${LN} -s $SCRIPT_DIR/.config/zed $HOME/.config
${LN} -s $SCRIPT_DIR/.config/bpytop $HOME/.config
${LN} -s $SCRIPT_DIR/.config/warp-terminal $HOME/.config

BIN_DIR=${SCRIPT_DIR}/bin
DEST_BIN_DIR=${HOME}/bin

if [[ ! -d ${DEST_BIN_DIR} ]]; then
    echo "creating ${DEST_BIN_DIR}"
    ${MD} ${DEST_BIN_DIR} || exit 1
fi

for path in $(find ${BIN_DIR} -type f -name '*.sh')
do
    filename="$(basename ${path%.*})"
    echo "linking ${path} to ${DEST_BIN_DIR}/${filename}"
    ${LN} -s ${path} ${DEST_BIN_DIR}/${filename}
done

