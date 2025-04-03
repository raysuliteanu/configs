#!/bin/bash

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

${BREW} update
# install from Brewfile
${BREW} bundle install
${BREW} cleanup

# install sdkman
curl -s "https://get.sdkman.io" | bash
if ! command -v sdk &>/dev/null; then
	echo "problem installing sdkman"
else
	sdk install java
	sdk install groovy
	sdk install gradle
	sdk install maven
	sdk install scala
	sdk install sbt
	sdk install springboot
fi

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# -- vim: ts=4 sts=4 sw=4 et
