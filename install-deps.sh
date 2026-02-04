#!/usr/bin/env bash

set -euo pipefail

BREW=brew
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# no-op the if executed with -x option
if [ "$-" = "x" ]; then
    BREW="echo brew"
    echo "BREW='${BREW}'"
else
    if ! command -v "${BREW}" &>/dev/null; then
        echo "${BREW} is not in the PATH. Is it installed?"
        read -rp "Do you want to try and install it? " answer
        case "$answer" in
        [yY])
            if ! command -v "git" &>/dev/null; then
                echo "Git is not in the PATH. It is required for Brew."
                read -rp "Do you want to try and install it? " answer
                case "$answer" in
                [yY])
                    apt-get install git
                    ;;
                *)
                    echo "exiting ..." && exit 1
                    ;;
                esac
            fi

            /bin/bash -c "$(curl -fsSL ${BREW_URL})" || exit 1
            ;;
        *)
            exit 1
            ;;
        esac
    fi
fi

${BREW} update
# install from Brewfile
${BREW} bundle install
${BREW} cleanup

# todo: run chezmoi init

# install sdkman
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/sdkman-install.sh" ]; then
    "${SCRIPT_DIR}/sdkman-install.sh"
else
    echo "Warning: sdkman-install.sh not found, skipping SDKMAN setup"
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM already installed, skipping..."
fi

# -- vim: ts=4 sts=4 sw=4 et
