#!/usr/bin/env bash

set -euo pipefail

# Test script for install-deps.sh
# Runs the installation in a Docker container to simulate a fresh system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="configs-test"
CONTAINER_NAME="configs-test-$$"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

cleanup() {
    if [ -n "${CONTAINER_NAME:-}" ]; then
        info "Cleaning up container..."
        docker rm -f "$CONTAINER_NAME" &>/dev/null || true
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Parse command-line options
INTERACTIVE=0
KEEP_CONTAINER=0
DRY_RUN=0
SCRIPT_TO_TEST="install-deps.sh"

while getopts "ikds:" opt; do
    case ${opt} in
    i)
        INTERACTIVE=1
        ;;
    k)
        KEEP_CONTAINER=1
        ;;
    d)
        DRY_RUN=1
        ;;
    s)
        SCRIPT_TO_TEST="${OPTARG}"
        ;;
    *)
        echo "Usage: $0 [-i] [-k] [-d] [-s script]"
        echo "  -i: Interactive mode (drop into shell instead of running script)"
        echo "  -k: Keep container after test (don't auto-cleanup)"
        echo "  -d: Dry run (show what would be executed)"
        echo "  -s: Script to test (default: install-deps.sh)"
        exit 1
        ;;
    esac
done

info "Building test Docker image..."
if [ "$DRY_RUN" -eq 1 ]; then
    info "[DRY RUN] Would build: docker build -f Dockerfile.test -t $IMAGE_NAME ."
else
    if ! docker build -f Dockerfile.test -t "$IMAGE_NAME" "$SCRIPT_DIR"; then
        error "Failed to build Docker image"
        exit 1
    fi
fi

if [ "$INTERACTIVE" -eq 1 ]; then
    info "Starting container in interactive mode..."
    if [ "$DRY_RUN" -eq 1 ]; then
        info "[DRY RUN] Would run: docker run --rm -it --name $CONTAINER_NAME $IMAGE_NAME"
    else
        docker run --rm -it --name "$CONTAINER_NAME" "$IMAGE_NAME"
    fi
else
    info "Running test script: $SCRIPT_TO_TEST"
    if [ "$DRY_RUN" -eq 1 ]; then
        if [[ "$SCRIPT_TO_TEST" == "install-deps.sh" ]]; then
            if [ -f "Brewfile.test" ]; then
                info "[DRY RUN] Would run: docker run --name $CONTAINER_NAME $IMAGE_NAME bash -c './$SCRIPT_TO_TEST -y -b Brewfile.test'"
            else
                info "[DRY RUN] Would run: docker run --name $CONTAINER_NAME $IMAGE_NAME bash -c './$SCRIPT_TO_TEST -y'"
            fi
        else
            info "[DRY RUN] Would run: docker run --name $CONTAINER_NAME $IMAGE_NAME bash -c 'yes | ./$SCRIPT_TO_TEST'"
        fi
    else
        # Run non-interactively (use -y flag for install-deps.sh)
        if [[ "$SCRIPT_TO_TEST" == "install-deps.sh" ]]; then
            # Use Brewfile.test if it exists, otherwise use default Brewfile
            if [ -f "Brewfile.test" ]; then
                TEST_CMD="./$SCRIPT_TO_TEST -y -b Brewfile.test"
            else
                TEST_CMD="./$SCRIPT_TO_TEST -y"
            fi
        else
            TEST_CMD="yes | ./$SCRIPT_TO_TEST"
        fi

        if docker run --name "$CONTAINER_NAME" "$IMAGE_NAME" bash -c "$TEST_CMD"; then
            info "✓ Test completed successfully!"

            if [ "$KEEP_CONTAINER" -eq 1 ]; then
                info "Container kept for inspection: $CONTAINER_NAME"
                info "To inspect: docker exec -it $CONTAINER_NAME bash"
                info "To remove: docker rm -f $CONTAINER_NAME"
                trap - EXIT # Disable cleanup trap
            fi
        else
            error "✗ Test failed!"

            info "Container logs:"
            docker logs "$CONTAINER_NAME"

            if [ "$KEEP_CONTAINER" -eq 1 ]; then
                warn "Container kept for debugging: $CONTAINER_NAME"
                info "To debug: docker exec -it $CONTAINER_NAME bash"
                info "To remove: docker rm -f $CONTAINER_NAME"
                trap - EXIT # Disable cleanup trap
            fi
            exit 1
        fi
    fi
fi

info "Test complete!"
