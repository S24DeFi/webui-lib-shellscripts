# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- `gnls` command to list GitNexus-indexed repos with index status and embedding counts
- `gnweb` command to start the GitNexus server and web UI from any folder
- `gnstop` command to stop the GitNexus server and web UI

## [2.4.0] - 2025-11-05

### Added

- Created `scripts/helpers.sh` module for shared utility functions
- Enhanced error handling with proper stderr redirection and return codes
- Input validation for all interactive functions
- Better error messages with usage instructions
- Automatic helpers.sh loading in setup (ensures proper dependency order)
- Added `syncenv` command to append missing keys from `.env.example` into `.env.local` or `.env`

### Fixed

- **CRITICAL**: Fixed duplicate shebang in `automation.sh` (line 40)
- **CRITICAL**: Fixed missing shebang at top of `automation.sh`
- Removed hardcoded paths from `personal.sh` note function
- Added proper error handling to all functions
- Improved branch existence checking in `newbranch` function
- Fixed environment variable validation in `pr` function

### Changed

- Consolidated utility functions (`trigger`, `showme`, `locate`, etc.) into `helpers.sh`
- Refactored all functions to use proper multi-line format with error handling
- Improved documentation with consistent headers and usage comments
- Enhanced `personal.sh` note function to use environment variables
- Standardized error output to stderr across all functions
- Updated setup.sh to load helpers.sh first (dependency management)
- Enhanced validation script to check for new helpers.sh module

### Improved

- Better input validation (numeric checks, file existence, etc.)
- Consistent error message formatting
- Function documentation with usage examples
- Script organization and separation of concerns

### Migration

- No breaking changes. All existing aliases and functions continue to work.
- New `helpers.sh` module is automatically loaded by setup script.

## [2.3.0] - 2025-10-13

### Added

- Added `pr()` function for interactive pull request navigation with project selection menu
- Enhanced pull request workflow with numbered project selection (1-10)
- Interactive menu system similar to existing automation functions

### Migration

- No breaking changes. All functions are auto-sourced as before.

## [2.2.0] - 2025-09-19

### Added

- Created `scripts/automation.sh` for workflow automation functions
- Moved functions to `automation.sh` for modularity

### Changed

- Improved script organization for easier maintenance and extension

### Migration

- No breaking changes. All functions are auto-sourced as before.

# Changelog

All notable changes to this project will be documented in this file.

## [2.1.0] - 2025-08-27

### Added

- Shell compatibility detection (bash/zsh support)
- Configuration duplicate prevention system
- `./setup.sh cleanup` command for safe configuration removal
- Automatic detection of existing configurations
- Enhanced error messages and troubleshooting guidance

### Fixed

- **CRITICAL**: Fixed "shopt: command not found" error on zsh shells
- **CRITICAL**: Fixed "no matches found" glob pattern errors
- **CRITICAL**: Prevented setup script from running multiple times
- Removed duplicate configuration entries in ~/.bashrc
- Fixed incorrect BashShells path pointing to wrong directories
- Enhanced glob pattern handling with NULL_GLOB for zsh

### Changed

- Setup script now detects shell type and uses appropriate commands
- Improved user experience with better error handling
- Cleaned up temporary and redundant files from repository
- Enhanced troubleshooting documentation

### Removed

- Temporary setup scripts (quick-setup.sh, manual-install.sh, etc.)
- Generated configuration files from repository
- Redundant template files

## [2.0.0] - 2025-08-27

### Added

- Interactive setup script (`setup.sh`) for automated configuration
- Organized directory structure with `config/`, `scripts/`, and `examples/` folders
- Comprehensive usage documentation (`USAGE.md`)
- Example usage scenarios
- Automatic backup of existing configurations
- Better error handling and user prompts
- Security improvements with git-ignored personal files

### Changed

- **BREAKING**: Moved configuration files to `config/` directory
  - `_bash-TEMPLATE.txt` → `config/bash-template.txt`
  - `_gitconfig.txt` → `config/gitconfig-template.txt`
- **BREAKING**: Moved all shell scripts to `scripts/` directory
- Updated README with cleaner, more focused instructions
- Improved file organization and structure
- Enhanced setup process with interactive prompts

### Fixed

- Updated file paths to work with new directory structure
- Fixed contrib.txt reference in personal.sh
- Added proper executable permissions to setup script

### Security

- Personal configuration files are now properly git-ignored
- Backup files created before any modifications
- No sensitive data stored in repository

## Migration Guide

If you have an existing setup, follow these steps:

1. **Backup your current configuration**:

   ```bash
   cp ~/.bashrc ~/.bashrc.backup
   cp ~/.gitconfig ~/.gitconfig.backup
   ```

2. **Update your repository**:

   ```bash
   git pull origin main
   ```

3. **Run the new setup**:

   ```bash
   ./setup.sh
   ```

4. **Restart your terminal or run**:
   ```bash
   source ~/.zshrc
   ```

## [1.0.0] - Previous

### Initial Features

- Basic shell script utilities
- Git aliases and enhancements
- Project navigation shortcuts
- Development tool helpers
- Testing utilities
