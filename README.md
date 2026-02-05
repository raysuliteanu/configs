# Misc Scripts

## Overview

Collection of scripts for setting up and managing development environment configurations.

## Misc config files

_NOTE_: configuration files have moved to <https://github.com/raysuliteanu/dotfiles>.

## Scripts

### install-deps.sh

Main installation script for setting up a new system. OS-agnostic (supports macOS and Linux).

**Usage:**

```bash
./install-deps.sh [-d] [-y] [-b brewfile]
```

**Options:**

- `-d` - Dry run mode (show what would be done without making changes)
- `-y` - Non-interactive mode (assume yes to all prompts, useful for automation)
- `-b` - Specify custom Brewfile to use (default: `Brewfile`, or `$BREWFILE` environment variable)

**Examples:**

```bash
# Standard installation
./install-deps.sh

# Use custom Brewfile
./install-deps.sh -b Brewfile.minimal

# Use environment variable
BREWFILE=Brewfile.test ./install-deps.sh -y

# Dry run with custom Brewfile
./install-deps.sh -d -b Brewfile.test
```

**Features:**

- Automatically detects OS (macOS/Linux)
- Installs Homebrew if not present
- Installs packages from Brewfile
- Sets up chezmoi with dotfiles
- Installs SDKMAN and SDKs
- Installs TPM (Tmux Plugin Manager)

### sdkman-install.sh

Installs SDKMAN and various SDKs (Java, Gradle, Kotlin, Maven, Scala, etc.)

### update-brewfile.sh

Updates the Brewfile with currently installed packages

## Testing Installation Scripts

The testing setup uses Docker to simulate a fresh Ubuntu 24.04 system, allowing you to test installation scripts without affecting your local environment.

### Files

- `Dockerfile.test` - Defines the test environment
- `test-install.sh` - Main test script with various testing modes
- `.dockerignore` - Excludes unnecessary files from Docker build context

### Prerequisites

- Docker installed and running
- Sufficient disk space for Ubuntu base image and packages

**Note on Linux Systems:** When using Homebrew on Linux to install gcc, a system C compiler (`cc`) is required as a prerequisite for gcc's postinstall step. This is needed even though you're installing gcc itself - the postinstall script uses the system compiler to locate C runtime files. The test Docker image includes `build-essential` to satisfy this requirement.

### Quick Start

#### Run Automated Test

Test the install script with automatic responses:

```bash
./test-install.sh
```

#### Interactive Mode

Drop into a shell to manually test and debug:

```bash
./test-install.sh -i
```

Once inside, you can run commands manually:

```bash
./install-deps.sh
```

### Usage Options

```bash
./test-install.sh [-i] [-k] [-d] [-s script]
```

#### Options

- `-i` **Interactive mode**: Opens a bash shell instead of running the script automatically
  - Useful for step-by-step testing and debugging
  - Example: `./test-install.sh -i`

- `-k` **Keep container**: Don't auto-cleanup the container after testing
  - Useful for inspecting the final state
  - Access with: `docker exec -it <container-name> bash`
  - Example: `./test-install.sh -k`

- `-d` **Dry run**: Show what would be executed without running it
  - Useful for verifying commands before execution
  - Example: `./test-install.sh -d`

- `-s` **Script to test**: Specify which script to test (default: install-deps.sh)

### Testing Workflows

#### 1. Full Integration Test

Test the complete installation from start to finish:

```bash
./test-install.sh
```

This will:

1. Build a fresh Ubuntu container
2. Run `install-deps.sh` with automatic yes responses
3. Show results and clean up

#### 2. Debug Failed Installation

If a test fails, keep the container for inspection:

```bash
./test-install.sh -k
```

Then inspect the container:

```bash
docker exec -it configs-test-<PID> bash
```

#### 3. Manual Step-by-Step Testing

For detailed investigation:

```bash
./test-install.sh -i
```

Inside the container:

```bash
# Test individual components
./update-brewfile.sh
./sdkman-install.sh

# Check installed tools
which brew
which sdk
which chezmoi

# Verify installations
brew --version
sdk version
```

#### 4. Test Individual Scripts

Test specific scripts in isolation:

```bash
./test-install.sh -s sdkman-install.sh
./test-install.sh -s update-brewfile.sh
```

#### 5. Test Idempotency

Verify scripts can be run multiple times safely:

```bash
./test-install.sh -i
```

Inside container:

```bash
# Run the script twice
./install-deps.sh
./install-deps.sh  # Should skip already-installed items
```

### Advanced Testing

#### Test Different Ubuntu Versions

Modify `Dockerfile.test` to change the base image:

```dockerfile
FROM ubuntu:22.04  # or ubuntu:23.10, etc.
```

#### Test with Custom Brewfile

Before running tests, modify your `Brewfile` to include/exclude packages.

#### Inspect Docker Image Layers

Use `dive` to analyze the built image:

```bash
dive configs-test
```

#### Test Network Conditions

Simulate slow/unreliable networks:

```bash
docker run --name test-net --network=none configs-test
```

### Common Issues and Solutions

#### Issue: Docker build fails

**Solution**: Ensure Docker daemon is running and you have internet connectivity

```bash
docker ps  # Verify Docker is running
```

#### Issue: Permission denied errors

**Solution**: The test user has sudo access. Prefix commands with `sudo` if needed:

```bash
sudo apt-get install something
```

#### Issue: Container won't start

**Solution**: Check Docker logs for details

```bash
docker logs configs-test-<PID>
```

#### Issue: Installation takes too long

**Solution**: Some packages (like LLVM, GCC) are large. Consider:

- Testing with a minimal Brewfile first
- Using Docker layer caching
- Running tests with specific script (`-s` option)

### Best Practices

1. **Start small**: Test individual scripts before running the full installation

2. **Use interactive mode**: When developing new features, use `-i` to test incrementally

3. **Keep containers for debugging**: Use `-k` when tests fail to inspect the state

4. **Test idempotency**: Always run scripts twice to ensure they handle re-runs gracefully

5. **Clean up**: Remove test containers and images periodically:

   ```bash
   docker system prune -a
   ```

6. **Version control**: Commit Dockerfile and test scripts to track testing infrastructure

### Continuous Integration

For CI/CD pipelines, use:

```bash
# In GitHub Actions, GitLab CI, etc.
./test-install.sh
```

Example GitHub Actions workflow:

```yaml
name: Test Installation Scripts
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run installation tests
        run: ./test-install.sh
```

### Troubleshooting

#### Get shell in running container

```bash
docker exec -it <container-name> bash
```

#### View container logs

```bash
docker logs <container-name>
```

#### List all test containers

```bash
docker ps -a | grep configs-test
```

#### Remove all test containers

```bash
docker ps -a | grep configs-test | awk '{print $1}' | xargs docker rm -f
```

#### Remove test image

```bash
docker rmi configs-test
```

## TODO

Write a script to check and/or install dependencies not installed by brew
(or better not installed by brew) e.g. rustup. Or find something that will do
the same thing e.g. would Nix HomeDir do it? Overkill?
