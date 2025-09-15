# TQ Energy Manager Application SDK
## Description
The Application Software Development Kit, or App SDK for short, enables the build of
the TQ Energy Manager toolchain.

## Commands
The Makefile supports the following commands:

### Main Target
- `make all` - Builds the complete toolchain including base, core, toolchain, demo app and bundle.

### Build Targets
- `make prepare` - Prepares the projects by running the preparation script.
- `make base` - Builds the base Docker image for Yocto builds.
- `make core` - Builds the core components (Yocto build) and deploys them.
- `make core-build` - Builds only the core components without deployment.
- `make core-deploy` - Deploys the core components.
- `make toolchain` - Builds the complete toolchain including the Yocto SDK.
- `make go-demo-app` - Builds and deploys the Go demo application.
- `make demo-bundle` - Builds and deploys the demo bundle.

### Documentation
- `make docs` - Builds the documentation (HTML and PDF).

### Testing
- `make test-all` - Build from scratch (removes Docker system cache).
- `make run-aarch64-bash` - Starts a bash shell in the aarch64 toolchain container for testing.

### Cleaning
- `make clean` - Cleans up build artifacts and docs directory.
- `make clean-demo` - Cleans only the demo app and bundle artifacts.
- `make clean-docker` - Removes unused Docker containers, networks, and images.
