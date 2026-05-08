#!/usr/bin/env bash

set -euo pipefail

# Configuration
DRY_RUN=0
NON_INTERACTIVE=0
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
# Single Brewfile override (empty = use Brewfile.common + Brewfile.<os>)
BREWFILE="${BREWFILE:-}"

# Parse command-line options
while getopts "dyb:" opt; do
    case ${opt} in
    d)
        DRY_RUN=1
        ;;
    y)
        NON_INTERACTIVE=1
        ;;
    b)
        BREWFILE="${OPTARG}"
        ;;
    *)
        echo "Usage: $0 [-d] [-y] [-b brewfile]"
        echo "  -d: Dry run mode (show what would be done)"
        echo "  -y: Non-interactive mode (assume yes to all prompts)"
        echo "  -b: Specify a single Brewfile (default: Brewfile.common + Brewfile.<os>)"
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# Detect OS
OS="$(uname -s)"
case "${OS}" in
Linux*) MACHINE=Linux ;;
Darwin*) MACHINE=Mac ;;
*) MACHINE="UNKNOWN:${OS}" ;;
esac

echo "Detected OS: ${MACHINE}"

# Helper function to run commands respecting dry-run mode
run_cmd() {
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[DRY RUN] Would execute: $*"
    else
        "$@"
    fi
}

# Helper function for prompts (respects non-interactive mode)
prompt_yes_no() {
    local prompt="$1"

    if [ "$NON_INTERACTIVE" -eq 1 ]; then
        echo "$prompt (non-interactive mode: assuming yes)"
        return 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[DRY RUN] Would prompt: $prompt"
        return 0
    fi

    read -rp "$prompt (y/n): " answer
    case "$answer" in
    [yY]) return 0 ;;
    *) return 1 ;;
    esac
}

# Initialize Homebrew environment
init_brew_env() {
    if command -v brew &>/dev/null; then
        eval "$(brew shellenv)"
        return 0
    fi

    # Try common installation paths based on OS
    local brew_paths=(
        "/opt/homebrew/bin/brew"              # macOS Apple Silicon
        "/usr/local/bin/brew"                 # macOS Intel
        "/home/linuxbrew/.linuxbrew/bin/brew" # Linux
    )

    for brew_path in "${brew_paths[@]}"; do
        if [ -x "$brew_path" ]; then
            echo "Initializing Homebrew from ${brew_path}..."
            eval "$("$brew_path" shellenv)"
            return 0
        fi
    done

    return 1
}

# Check for git (required for Homebrew)
if ! command -v "git" &>/dev/null; then
    echo "Git is not in the PATH. It is required for Homebrew."
    if prompt_yes_no "Do you want to try and install it?"; then
        case "${MACHINE}" in
        Mac)
            echo "On macOS, installing Xcode Command Line Tools..."
            if [ "$DRY_RUN" -eq 1 ]; then
                echo "[DRY RUN] Would execute: xcode-select --install"
            else
                xcode-select --install
                echo "Please re-run this script after installation completes."
                exit 0
            fi
            ;;
        Linux)
            if command -v apt-get &>/dev/null; then
                run_cmd sudo apt-get install -y git
            elif command -v dnf &>/dev/null; then
                run_cmd sudo dnf install -y git
            elif command -v pacman &>/dev/null; then
                run_cmd sudo pacman -S --noconfirm git
            else
                echo "Error: Unable to detect package manager. Please install git manually."
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS: ${MACHINE}"
            exit 1
            ;;
        esac
    else
        echo "exiting ..."
        exit 1
    fi
fi

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew is not in the PATH."
    if prompt_yes_no "Do you want to try and install it?"; then
        if [ "$DRY_RUN" -eq 1 ]; then
            echo "[DRY RUN] Would execute: /bin/bash -c \"\$(curl -fsSL ${BREW_URL})\""
        else
            /bin/bash -c "$(curl -fsSL ${BREW_URL})" || exit 1
        fi

        # Initialize Homebrew environment after installation
        if [ "$DRY_RUN" -eq 0 ]; then
            if ! init_brew_env; then
                echo "Error: Homebrew installed but cannot be found"
                exit 1
            fi
        fi
    else
        exit 1
    fi
else
    # Ensure brew environment is initialized
    if [ "$DRY_RUN" -eq 0 ]; then
        init_brew_env
    fi
fi

# Verify brew is now available (skip in dry-run mode)
if [ "$DRY_RUN" -eq 0 ]; then
    if ! command -v brew &>/dev/null; then
        echo "Error: brew command not available after initialization"
        exit 1
    fi
fi

echo "Running Homebrew operations..."
run_cmd brew update

if [ -n "${BREWFILE}" ]; then
    echo "Using Brewfile: ${BREWFILE}"
    if [ "$DRY_RUN" -eq 0 ] && [ ! -f "${BREWFILE}" ]; then
        echo "Error: Brewfile '${BREWFILE}' not found"
        exit 1
    fi
    run_cmd brew bundle install --file="${BREWFILE}"
else
    OS_LOWER=$(uname -s | tr '[:upper:]' '[:lower:]')
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    for bf in "${SCRIPT_DIR}/Brewfile.common" "${SCRIPT_DIR}/Brewfile.${OS_LOWER}"; do
        if [ -f "$bf" ]; then
            echo "Using Brewfile: ${bf}"
            run_cmd brew bundle install --file="${bf}"
        else
            echo "Warning: ${bf} not found, skipping"
        fi
    done
fi

run_cmd brew cleanup

# Initialize chezmoi with dotfiles repository
echo "Setting up chezmoi..."
if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY RUN] Would check for chezmoi and initialize if needed"
elif command -v chezmoi &>/dev/null; then
    if [ ! -d "$HOME/.local/share/chezmoi" ]; then
        echo "Initializing chezmoi with dotfiles repository..."
        chezmoi init https://github.com/raysuliteanu/dotfiles
    else
        echo "Chezmoi already initialized, skipping..."
    fi
else
    echo "Warning: chezmoi not found in PATH, skipping initialization"
fi

# Install mise-managed runtimes
echo "Setting up mise runtimes..."
if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY RUN] Would execute: mise install"
elif command -v mise &>/dev/null; then
    mise install
else
    echo "Warning: mise not found in PATH, skipping runtime setup"
fi

# Install TPM (Tmux Plugin Manager)
echo "Setting up TPM..."
if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY RUN] Would check for TPM and clone if needed"
elif [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM already installed, skipping..."
fi

echo ""
echo "Installation complete!"
if [ "$DRY_RUN" -eq 1 ]; then
    echo "(This was a dry run - no actual changes were made)"
fi
echo ""
echo "*** REMINDER: run \`chezmoi apply\`"

# -- vim: ts=4 sts=4 sw=4 et
