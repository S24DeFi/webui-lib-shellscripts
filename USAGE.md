# Shell Script Utilities - Usage Guide

## Quick Start Commands

After setup, these are the most commonly used commands:

### Essential Commands

| Command            | Description                           | Example      |
| ------------------ | ------------------------------------- | ------------ |
| `go`               | Reload shell configurations           | `go`         |
| `showme <keyword>` | Search for aliases containing keyword | `showme git` |
| `list`             | Show all available aliases            | `list`       |
| `msg`              | Show git status and recent commits    | `msg`        |

### Navigation Commands

| Command    | Description                             | Example    |
| ---------- | --------------------------------------- | ---------- |
| `app`      | Go to workspace and list projects       | `app`      |
| `projects` | List all projects in workspace          | `projects` |
| `app1`     | Navigate to your first app project      | `app1`     |
| `app2`     | Navigate to your second app project     | `app2`     |
| `lib`      | Navigate to your shared library project | `lib`      |
| `tools`    | Navigate to this utility project        | `tools`    |

> **Note**: Project navigation shortcuts are personal — define yours in `scripts/personal.sh`.

> **Tip**: If your workspace is inside iCloud or a path with smart quotes/non-ASCII characters, create an ASCII-only symlink such as `~/alias-workspace` and rerun `./setup.sh` from that symlinked repo path.

### Development Commands

| Command                                | Description                                              | Example                           |
| -------------------------------------- | -------------------------------------------------------- | --------------------------------- |
| `nocors`                               | Open Chrome with CORS disabled                           | `nocors`                          |
| `ticket <number>`                      | Open JIRA ticket in browser                              | `ticket 1234`                     |
| `cvg`                                  | Open test coverage report                                | `cvg`                             |
| `gar [path]`                           | Generate an Allure report from `allure-results`          | `gar ../deployments/webapp-cvu`   |
| `vers`                                 | Show versions of dev tools                               | `vers`                            |
| `syncenv [example_file] [target_file]` | Append missing env keys without overwriting local values | `syncenv .env.example .env.local` |

### Git Commands

| Command         | Description                                  | Example         |
| --------------- | -------------------------------------------- | --------------- |
| `gcom`          | Checkout and update master branch            | `gcom`          |
| `newbranch`     | Interactively create and checkout new branch | `newbranch`     |
| `gpod`          | Push current branch to origin                | `gpod`          |
| `cleanbranches` | List orphaned local branches (safe preview)  | `cleanbranches` |
| `cleanorphans`  | Delete orphaned local branches               | `cleanorphans`  |
| `cleanlocalbranches` | Delete merged/closed-PR local branches still on remote | `cleanlocalbranches [-y]` |
| `msg`           | Show git status with recent commits          | `msg`           |

#### Branch Cleanup Details

`cleanbranches` and `cleanorphans` use a two-stage safety pattern:

```bash
cleanbranches   # Preview: lists branches that will be deleted
cleanorphans    # Action: actually delete orphaned branches
```

**Customization** (set in `scripts/personal.sh` or shell rc):

```bash
# Protect additional branches from deletion
export SKILLS_PROTECTED_BRANCHES="master main develop release-*"

# Use a different git remote
export SKILLS_GIT_REMOTE="upstream"
```

Default protected branches: `master` and `main`
Default remote: `origin`

### Testing Commands

| Command      | Description                                    | Example                         |
| ------------ | ---------------------------------------------- | ------------------------------- |
| `yt`         | Run tests                                      | `yt`                            |
| `ytc`        | Run tests with coverage report                 | `ytc`                           |
| `ytf`        | Run tests, show only failures                  | `ytf`                           |
| `yw <file>`  | Run tests in watch mode for a file             | `yw src/button.test.ts`         |
| `gar [path]` | Generate `allure-report` from `allure-results` | `gar ../deployments/webapp-cvu` |

> **Note**: Add project-specific test runners in `scripts/personal.sh`.

### Utility Commands

| Command     | Description                         | Example     |
| ----------- | ----------------------------------- | ----------- |
| `cg`        | Clear screen and go to project root | `cg`        |
| `cls`       | Clear screen                        | `cls`       |
| `ok`        | List files with count               | `ok`        |
| `grabshots` | Move screenshots to current folder  | `grabshots` |

### Network Utilities

| Command | Description                    | Example |
| ------- | ------------------------------ | ------- |
| `myip`  | Display your public IP address | `myip`  |

**Customization** (set in `scripts/personal.sh` or shell rc):

```bash
# Use an alternative IP lookup service
export SKILLS_MYIP_URL="https://checkip.amazonaws.com"
```

Default IP service: `http://ipecho.net/plain`

### Environment Sync

`syncenv` copies only missing `KEY=value` lines from an example env file into your local env file.

```bash
syncenv
syncenv .env.example .env
syncenv config/.env.sample .env.local
```

- Defaults to `.env.example`
- Uses `.env.local` when it exists, otherwise `.env`
- Never overwrites values already present in the target file
- Returns an error if the example file or target file cannot be found

## Alternative Usage: Modular Entry Point (hub.sh)

Instead of using `setup.sh` to modify your shell rc files, you can source `hub.sh` directly for project-level or portable usage:

```bash
source /path/to/webui-lib-shellscripts/scripts/hub.sh
```

This loads all utilities into the current shell session without modifying `~/.bashrc` or `~/.zshrc`.

### When to Use hub.sh

- **Project-specific initialization:** Source in project `.shellscriptrc` or `.sh-init`
- **Containerized environments:** Load utilities in Dockerfile or container startup script
- **CI/CD pipelines:** Initialize utilities in workflow steps
- **Shared machines:** Avoid modifying global shell configuration
- **Temporary tooling:** Load utilities for a single session

### Example: Project-Level Shell Config

**File: `.shell-config` in project root**

```bash
#!/bin/bash
# Load utilities for this project
source ~/.local/webui-lib-shellscripts/scripts/hub.sh

# Project-specific aliases
alias build="yarn build"
alias test="yarn test --watch"
alias serve="yarn dev"

# Project-specific environment
export API_URL="http://localhost:8000"
```

**Usage:**

```bash
cd my-project
source .shell-config
# Now all utilities + project aliases are available
build    # runs yarn build
```

### Comparison: setup.sh vs hub.sh

See [README.md#distribution-modes](README.md#-distribution-modes) for detailed comparison table.

## Project Activation with activate-hub

Initialize any project with project-specific shell configuration and AI skills folder.

### Quick Start

```bash
cd /path/to/your-project
activate-hub
```

This creates:

- **`.shell-config`** — Project shell initialization (sources hub.sh)
- **`skills/`** — Folder for AI agent instructions
- **`skills/<PROJECT>.md`** — Boilerplate skill documentation

### Using Your Project Hub

After activation:

```bash
cd /path/to/your-project
source .shell-config                # Activate project utilities

# All core utilities available
myip                                # Network
cleanbranches                       # Git
syncenv                             # Environment
showme help                         # Discover more
```

### Customize .shell-config

Edit `.shell-config` to add project-specific commands:

```bash
#!/bin/bash
# ... (hub.sh load code)

# Project-specific aliases
alias build="yarn build"
alias test="yarn test --watch"
alias dev="yarn dev"

# Project environment
export API_URL="http://localhost:8000"
export DEBUG=true
```

### Set Up Project Skills

Edit `skills/<PROJECT>.md` to document:

- Project structure and conventions
- Technology stack
- Coding patterns and styles
- Build/test/deploy procedures
- API endpoints and integrations
- Setup instructions

This helps AI agents (GitHub Copilot, etc.) generate better code and understand your project context.

### Example Project Structure

```
my-awesome-app/
├── .shell-config                   # Project shell init
├── skills/
│   ├── my-awesome-app.md          # Main project skills (edit me!)
│   ├── architecture.md            # Architecture decisions
│   └── feature-workflow.md        # Feature guidelines
├── src/
├── tests/
├── package.json
└── ...
```

### Sharing Projects

When sharing a project with your team:

1. Include `.shell-config` in version control
2. Include `skills/` folder in version control
3. Team members can run `source .shell-config` immediately
4. AI agents have full project context

## File Organization

```
tool-development-utility/
├── README.md              # Main documentation
├── USAGE.md              # This usage guide
├── setup.sh              # Main setup script
├── config/               # Configuration templates
│   ├── bash-template.txt
│   └── gitconfig-template.txt
├── scripts/              # All shell script modules
│   ├── helpers.sh        # Shared utility functions (loaded first)
│   ├── hub.sh            # Alternative modular entry point (optional)
│   ├── base.sh           # Core utilities and aliases
│   ├── networking.sh     # Network utilities (myip)
│   ├── automation.sh     # Workflow automation functions
│   ├── shortcuts.sh      # Project navigation shortcuts
│   ├── sprouts.sh        # SkillSprouts iOS workflows
│   ├── personal.sh       # Your personal customizations (git-ignored)
│   └── contrib.txt       # Git contribution analysis
└── examples/            # Usage examples
```

## Customization

### Adding New Aliases

1. Edit the appropriate script in `scripts/` directory
2. Add your alias following the existing pattern
3. Run `go` to reload configurations

### Creating New Script Modules

1. Create a new `.sh` file in the `scripts/` directory
2. Add your aliases and functions
3. The setup will automatically load it on next `go` command

### Environment Variables

The following variables are available in all scripts:

- `$UserName` - Your username
- `$UserId` - Your org/employee ID (optional)
- `$JiraUserid` - Your JIRA account ID (optional)
- `$CodeId` - Your GitHub username
- `$Workspace` - Your workspace path
- `$BashShells` - Path to this utility

## Troubleshooting

### Commands Not Found

- Run `go` to reload configurations
- Check if setup was completed successfully
- Verify scripts have execute permissions

### Git Issues

- Run `git config --list` to verify git configuration
- Check if your git credentials are properly set

### Path Issues

- Ensure workspace paths are correct in configuration
- Use absolute paths when in doubt
- Prefer an ASCII-only symlink such as `~/alias-workspace` when your real workspace path contains iCloud naming or smart quotes

## Security Notes

- Personal configuration files are git-ignored
- Backup files are created before modifications
- Sensitive information should not be committed

## Contributing

1. Create a new branch for your changes
2. Test your modifications thoroughly
3. Update documentation if needed
4. Submit a pull request
