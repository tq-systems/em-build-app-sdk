# TQ Energy Manager Application SDK
## Description
The Application Software Development Kit, or App SDK for short, enables the build of
the TQ Energy Manager toolchain.

## Components

Building the toolchain is made possible by the following components
that are dependant on each other in this order:

- base
  Provides docker-based build environments for consistent builds

- yocto
  Generates images for the lowlevel ARM64 hardware support and operating system

- em-build
  Combines Yocto metalayers that contain recipes for building operating system and rootfs

- toolchain
  Cross-compilation environment for ARM64 application builds

- go-demo-app
  Reference Go implementation of an exemplary app

- demo-bundle
  Reference bundle implementation to collect multiple apps into a single package

## First steps

### Prerequisites

Building the App SDK requires the following host packages:
- docker
- make
- git

### Getting started

Clone the App SDK repository to your machine:

- `git clone https://github.com/tq-systems/em-build-app-sdk`

Then change into the `em-build-app-sdk` directory and use one of the
make commands to start building.

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

### Releases
New versions of this App-SDK project are published as `Github Releases`.
We recommend to always rely on versions released as `Github Releases` as
they passed substantial QA procedures. Any in-between stages or tags
could still contain bugs and faults not yet detected by QA.

If you wish to be notified upon new `Github Releases` you can subscribe to events
on Github:
- Open `https://github.com/tq-systems/em-build-app-sdk`
- Select `Watch` in the header (visible when logged in)
- Choose a notification option, e.g. `Custom`
- Select `Releases` to receive an e-mail notification on new App-SDK releases

## Further reference

Please also consider the project specific READMEs.
