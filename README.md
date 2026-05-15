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

For local frontend development (`make frontend-dev`) the following additional packages are required:
- Node.js 22 or later
- yarn (install via `corepack enable` after installing Node.js)

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

### Frontend Development
- `make frontend-dev` - Starts a local frontend development environment for a single
  app frontend against a running gateway. The UI-Server is any repository that hosts
  the shell application loading the app frontends (for example the public
  `em-app-open-ui-container`). The target performs the following steps:

  1. Clones the UI-Server repository into `TQEM_UI_SERVER_DIR` (or updates
     an existing checkout) and checks out `TQEM_UI_SERVER_VERSION`.
  2. Generates a `.env` in the UI-Server with the branding and gateway URL.
  3. Symlinks the app's vite build output directory
     (`<APP_DIR>/container/frontend/apps/<APP_ID>/`) into the UI-Server's
     `frontend/apps/<APP_ID>/`, so the dev server can serve the built bundles.
  4. Writes `apps.json` and `langs.json` so the UI-Server knows which app
     entry points to load.
  5. Runs `yarn install` in both the UI-Server and the app frontend.
  6. Starts the app's vite watch build in the background and the UI-Server
     dev server in the foreground. The dev server proxies `/api` to the gateway.

  Required variables:
  - `TQEM_FRONTEND_APP_ID` - App identifier (e.g. `go-demo`)
  - `TQEM_FRONTEND_APP_DIR` - Absolute path to the app's `frontend/` directory
  - `TQEM_TARGET_URL` - URL of a running Energy Manager gateway (e.g. `http://192.168.1.100`)

  Optional variables:
  - `TQEM_BRANDING` - UI branding to use (default: `default`)
  - `TQEM_UI_SERVER_REPO` - UI-Server git repository URL (default: public GitHub repo)
  - `TQEM_UI_SERVER_VERSION` - UI-Server branch or tag to use (default: `main`)
  - `TQEM_UI_SERVER_DIR` - Directory the UI-Server is cloned into
    (default: `build/apps/ui-server` inside the App SDK)
  - `TQEM_FRONTEND_DEV_HOST` - Bind address of the dev server (default: `0.0.0.0`,
    reachable from other machines on the network). Set to `127.0.0.1` to expose
    only on the local machine.

  Example:
  ```
  make frontend-dev \
    TQEM_FRONTEND_APP_ID=go-demo \
    TQEM_FRONTEND_APP_DIR=/path/to/go-demo/frontend \
    TQEM_TARGET_URL=http://192.168.1.100
  ```

  Once started, the dev server is reachable at `http://<host>:5173/`. Source
  changes in the app frontend trigger an incremental rebuild and the browser
  reloads automatically.

- `make frontend-dev-check` - Validates that all required `TQEM_*` variables for
  `frontend-dev` are set. Does not clone, install or start anything; safe for CI.

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

## License Information
All files in this project are classified as product-specific software and bound
to the use with the TQ-Systems GmbH product: EM400

    SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3
