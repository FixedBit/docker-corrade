# Change Log for "Docker Corrade"

## [2022-01-31]
### Changed
- Fixed some minor bugs in the build.sh script
- Added some better checking into the build.sh script to handle building and pushing tags
- Changed docker-compose example to use ${PWD} for greater compatibility
### Added
- Migration code per the Corrade team to handle the new Configuration file formatting
- Added a docker-compose version of the config to show example of binding existing config files into run.sh

## [2022-01-08]
### Changed
- Fixed the run file so that it fixes permissions and loads in default configuration files if none are found
- Updated Dockerfile to use user 1000 since... Well I do not know why it wasn't before!
- Publishing this at 11:30pm on the 7th and putting the 8th just because I feel like being in the future!

## [2022-01-07]
### Added
- "CHANGELOG.md" to help keep track of changes to this build setup
### Changed
- Dockerfile now handles all of the needed work for downloading and setting up Corrade in the container
- Build script now relies on arguments instead of overrides for build options
- "README.md" updated to better explain how to use build script
### Removed
- "files/setup.sh" as it is no longer needed
