#!/bin/bash

BREW=brew
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# no-op the if executed with -x option
if [ "$-" = "x" ]; then
    BREW="echo brew"
    echo "BREW='${BREW}'"
else
    command -v "${BREW}" &>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "${BREW} is not in the PATH. Is it installed?"
        read -p "Do you want to try and install it? " answer
        case "$answer" in
        [yY])
            command -v "git" &>/dev/null
            if [[ $? -ne 0 ]]; then
                echo "Git is not in the PATH. It is required for Brew."
                read -p "Do you want to try and install it? " answer
                case "$answer" in
                [yY])
                    # Ubuntu:
                    apt-get install git
                    # Arch:
                    pacman -Sy && pacman -S git
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

${BREW} update && ${BREW} upgrade

${BREW} tap homebrew/bundle
${BREW} tap homebrew/services

${BREW} install awscli
${BREW} install bat
${BREW} install bottom
${BREW} install bpftop
${BREW} install bpytop
${BREW} install chezmoi
${BREW} install clipboard
${BREW} install cmake-docs
${BREW} install compiledb
${BREW} install curlie
${BREW} install dive
${BREW} install dnstop
${BREW} install dust
${BREW} install emacs
${BREW} install eza
${BREW} install fd
${BREW} install fzf
${BREW} install gh
${BREW} install git-delta
${BREW} install git-lfs
${BREW} install glances
${BREW} install gradle
${BREW} install groovy
${BREW} install httpie
${BREW} install jj
${BREW} install jq
${BREW} install kind
${BREW} install kubernetes-cli
${BREW} install lazygit
${BREW} install llvm
${BREW} install maven
${BREW} install neovim
${BREW} install ripgrep
${BREW} install rustup
${BREW} install socat
${BREW} install tldr
${BREW} install tmux
${BREW} install zoxide

# optional dependencies
if [ "${1}" = "with-optional" ]; then
    echo "installing optional dependencies ..."
    ${BREW} install auth0/auth0-cli/auth0
    ${BREW} install bison
    ${BREW} install boost
    ${BREW} install buildpacks/tap/pack
    ${BREW} install clisp
    ${BREW} install clojure
    ${BREW} install confluentinc/tap/cli
    ${BREW} install dtc
    ${BREW} install erlang
    ${BREW} install flex
    ${BREW} install gcc
    ${BREW} install git-cliff
    ${BREW} install go
    ${BREW} install googletest
    ${BREW} install grpcurl
    ${BREW} install helm
    ${BREW} install htop
    ${BREW} install just
    ${BREW} install kafka
    ${BREW} install kcat
    ${BREW} install kustomize
    ${BREW} install leiningen
    ${BREW} install lua
    ${BREW} install luarocks
    ${BREW} install markdownlint-cli2
    ${BREW} install mercurial
    ${BREW} install meson
    ${BREW} install neo4j
    ${BREW} install nethack
    ${BREW} install nftables
    ${BREW} install node
    ${BREW} install pigz
    ${BREW} install pre-commit
    ${BREW} install skaffold
    ${BREW} install taskwarrior-tui
    ${BREW} install tfenv
    ${BREW} install tgenv
    ${BREW} install zellij
else
    echo "skipping optional dependencies!"
fi

${BREW} cleanup

# -- vim: ts=4 sts=4 sw=4 et
