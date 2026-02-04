#!/usr/bin/env bash

# install sdkman; requires curl so need to install Brewfile stuff first
if [ ! -d "$HOME/.sdkman" ]; then
    curl -s "https://get.sdkman.io" | bash
else
    echo "SDKMAN is already installed."
fi

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

sdk version

sdk install gradle
sdk install groovy
sdk install java
sdk install kotlin
sdk install maven
sdk install micronaut
sdk install quarkus
sdk install sbt
sdk install scala
sdk install springboot
