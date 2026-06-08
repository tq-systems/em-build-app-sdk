## [0.2.0] - 2026-05-28
### Added
- frontend-dev make target that drives a local development environment for an app frontend against
  a UI-Server without a git submodule, plus a frontend-dev-check smoke target exercised in CI
- App: open-ui-container
- projects.yml: select fixed versions

### Fixed
- docker-run.sh: assign DOCKER_GID to CURRENT_GID instead of CURRENT_UID and build TQEM env -e
  arguments as a quoted array so multi-line CI variables no longer mangle the docker run invocation

### Changed
- docs: update docs

## [0.1.2] - 2026-02-24
### Changed
- Updated the toolchain

## [0.1.1] - 2025-11-24
### Changed
- Updated the go-demo application

## [0.1.0] - 2025-11-18
