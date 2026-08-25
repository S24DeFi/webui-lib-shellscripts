# 🔧 shell-hub

A modular collection of shell scripts and aliases for bash/zsh, sourced through a single `hub.sh` entry point via `activate-hub`. Drop it into any project to get git branch management, project navigation, networking helpers, and workflow automation without wiring each script up by hand.

[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](CHANGELOG.md)
[![Shell](https://img.shields.io/badge/shell-bash%2Fzsh-green.svg)](setup.sh)
[![Platform](https://img.shields.io/badge/platform-macOS%2FLinux-lightgrey.svg)](#prerequisites)

## ✨ Features

- **🚀 Project Navigation** - Quick shortcuts to navigate between projects
- **🔄 Git Utilities** - Enhanced git commands and branch management
- **💬 Contextual Prompt** - Show the current folder and git branch in your prompt
- **🧪 Development Tools** - Testing, building, and debugging helpers
- **⚡ Automation** - Common task automation and workflow optimization
- **📚 Interactive Setup** - Guided configuration with automatic backups
- **🔒 Security-First** - Personal data separation and safe configuration

## 🎯 Quick Start

### One-Command Setup

```bash
git clone <repository-url>
cd tool-development-utility
./setup.sh
```

The interactive setup will:

- ✅ Check for existing configurations (prevents duplicate setups)
- ✅ Backup your existing configurations automatically
- ✅ Guide you through personalization with smart defaults
- ✅ Generate shell-compatible configuration (bash/zsh)
- ✅ Set up all aliases and shortcuts
- ✅ Verify everything works correctly

### Cleanup and Reconfiguration

```bash
./setup.sh cleanup  # Remove existing configuration
./setup.sh          # Run fresh setup
```

If your workspace lives in iCloud or under a path with smart quotes/non-ASCII characters, create an ASCII-only symlink first and rerun setup from that path:

```bash
ln -s "/Users/you/Desktop/Desktop - Your Name’s MacBook/workspace" "$HOME/alias-workspace"
cd "$HOME/alias-workspace/alias-webapp-lib"
./setup.sh
```

When present, setup now prefers `~/alias-workspace` or `~/workspace` symlinks that point at the current repo.

### Start Using Immediately

```bash
source ~/.zshrc   # primary shell config on macOS
go               # reload configurations
showme help      # discover available commands
```

## � Distribution Modes

This project supports **two complementary usage patterns**:

### Mode 1: Interactive Setup (One-Time Configuration)

**Best for:** Daily development terminal with persistent shell rc configuration.

```bash
./setup.sh
```

This modifies your `~/.bashrc` or `~/.zshrc` to automatically load all utilities on shell startup. After setup:

- All 170+ commands available in every new terminal session
- Personalized prompt with git branch info
- Persistent across shell restarts
- One-time configuration required

**Advantages:**

- ✅ Automatic on every shell startup
- ✅ Personalized user configuration
- ✅ Git aliases and prompt included
- ✅ Built-in backup/cleanup support

### Mode 2: Modular Sourcing (Project-Level or Portable)

**Best for:** Project-specific shells, containers, CI/CD, or portable workflows.

```bash
source /path/to/webui-lib-shellscripts/scripts/hub.sh
```

This loads all utilities into the current shell session without modifying any rc files. Useful for:

- Project-specific shell initialization
- Containerized environments
- Shared development environments (don't modify global config)
- Temporary tooling needs

**Advantages:**

- ✅ No shell rc modifications
- ✅ Project-level isolation
- ✅ Container/CI-friendly
- ✅ Portable across shells

**Example: Project .shellscriptrc**

```bash
#!/bin/bash
# Load utilities for this project
source ~/.local/webui-lib-shellscripts/scripts/hub.sh

# Define project-specific aliases
alias build="yarn build && echo 'Build complete'"
alias test="yarn test --watch"
```

Then use: `source .shellscriptrc` in project root.

### Mode Comparison

| Feature                | setup.sh | hub.sh                  |
| ---------------------- | -------- | ----------------------- |
| Shell rc modification  | ✅ Yes   | ❌ No                   |
| One-time setup needed  | ✅ Yes   | ❌ No                   |
| Automatic on startup   | ✅ Yes   | ❌ No                   |
| Project isolation      | ❌ No    | ✅ Yes                  |
| Container-friendly     | ❌ No    | ✅ Yes                  |
| All commands available | ✅ Yes   | ✅ Yes                  |
| Git prompt integration | ✅ Yes   | ✅ Yes (via helpers.sh) |

## 🚀 Project Activation: initialize-hub

For **project-level setup**, use the `activate-hub` command to initialize a project with:

- **`.shell-config`** — Project-specific shell initialization (sources hub.sh locally)
- **`skills/`** — Folder for AI agent instructions and domain knowledge
- **`skills/<PROJECT>.md`** — Boilerplate skill template with YAML frontmatter

### Quick Start: Activate a Project

```bash
cd /path/to/your-project
activate-hub
```

This does:

1. ✅ Creates `.shell-config` (template for project-specific aliases/env vars)
2. ✅ Creates `skills/` folder (for AI skills and agent context)
3. ✅ Creates `skills/<PROJECT>.md` (boilerplate with documentation)
4. ✅ Shows setup instructions

### Using the Project Configuration

After activation:

```bash
cd /path/to/your-project
source .shell-config              # Load project utilities

# Now all core utilities are available, plus your project-specific aliases
myip                              # Network utilities
cleanbranches                      # Git utilities
build                             # Project-specific (if you define it)
```

### Project Structure After activate-hub

```
my-project/
├── .shell-config                 # Project shell initialization
├── skills/
│   ├── my-project.md             # Main project skills (edit this!)
│   ├── architecture.md           # (optional) Architecture guidelines
│   └── feature-workflow.md       # (optional) Feature development guide
├── src/
├── package.json
└── ...
```

### Customizing `.shell-config`

Edit `.shell-config` to add project-specific commands:

```bash
# Project-specific aliases
alias build="yarn build"
alias test="yarn test --watch"
alias serve="yarn dev"

# Project environment
export API_URL="http://localhost:8000"
export DEBUG=true
```

### AI Skills: Document Your Project

The `skills/` folder helps AI agents generate better code and find bugs. Edit `skills/<PROJECT>.md` to include:

- **Project structure** — Folder organization and conventions
- **Tech stack** — Framework versions and dependencies
- **Coding patterns** — Your team's established practices
- **Build/test workflows** — Commands and CI/CD steps
- **API/endpoint docs** — Integration points
- **Setup instructions** — How to get the dev environment running

Example:

```markdown
# My Project Skills

## Project Structure

- `src/` — React components and logic
- `tests/` — Jest test files
- `config/` — Build configuration

## Coding Conventions

- Use functional components with hooks
- Props validation with PropTypes
- CSS modules for styling

## Build & Deploy

- `yarn build` — Production build
- `yarn test` — Run test suite
- `yarn dev` — Start dev server
```

### Benefits

- ✅ **Portable** — Share `.shell-config` + `skills/` with team
- ✅ **Consistent** — Same utilities across all projects
- ✅ **AI-friendly** — Agents have project context
- ✅ **Flexible** — Customize per project as needed

---

## 📋 Prerequisites

- **Git** - Git should be installed and configured
- **macOS/Linux** - Designed for Unix-based systems
- **Shell** - Works with bash, zsh, and most POSIX shells

## 🎮 Most Used Commands

| Command            | Purpose                                           | Example                         |
| ------------------ | ------------------------------------------------- | ------------------------------- |
| `go`               | Reload all configurations and refresh the prompt  | `go`                            |
| `showme <keyword>` | Search for commands                               | `showme git`                    |
| `list`             | Show all available aliases                        | `list`                          |
| `msg`              | Git status and recent commits                     | `msg`                           |
| `app`              | Navigate to workspace                             | `app`                           |
| `nocors`           | Open Chrome without CORS                          | `nocors`                        |
| `gar [path]`       | Generate an Allure report                         | `gar ../deployments/webapp-cvu` |
| `syncenv`          | Append missing env keys from `.env.example`       | `syncenv`                       |
| `cleanbranches`    | List orphaned git branches (safe preview)         | `cleanbranches`                 |
| `cleanorphans`     | Delete orphaned local git branches                | `cleanorphans`                  |
| `myip`             | Get public IP address                             | `myip`                          |
| `activate-hub`     | Initialize project with .shell-config and skills/ | `activate-hub`                  |
| `ticket <number>`  | Open JIRA ticket                                  | `ticket 1234`                   |

## 📁 Project Structure

```
tool-development-utility/
├── 📄 README.md              # This getting started guide
├── 📖 USAGE.md               # Comprehensive command reference
├── 📝 CHANGELOG.md           # Version history and changes
├── 🔧 setup.sh               # Interactive setup script with cleanup
├── ⚙️  config/               # Configuration templates
│   ├── bash-template.txt     # Shell configuration template
│   └── gitconfig-template.txt# Git aliases and settings
├── 📜 scripts/               # Modular shell scripts
│   ├── helpers.sh            # Shared utility functions (loaded first)
│   ├── hub.sh                # Alternative modular entry point (optional)
│   ├── base.sh               # Core utilities and aliases
│   ├── networking.sh         # Network utilities (myip)
│   ├── automation.sh         # Workflow automation functions
│   ├── shortcuts.sh          # Project navigation shortcuts
│   ├── sprouts.sh            # SkillSprouts-specific workflows
│   ├── personal.sh           # Your personal customizations (git-ignored)
│   └── contrib.txt           # Git contribution analysis
└── 📚 examples/              # Usage examples and scenarios
    └── usage-examples.md     # Common workflow examples
```

## 🎯 Key Capabilities

### Project Navigation

```bash
# Define shortcuts to your own projects in personal.sh:
app1       # → your-app-project
app2       # → your-other-app
lib        # → your-shared-library
tools      # → this utility project
```

### Git Enhancement

```bash
msg        # Enhanced git status with recent commits
gcom       # Checkout and update master
newbranch  # Create and switch to new branch
gpod       # Push current branch to origin
cleanbranches  # List orphaned branches (safe preview)
cleanorphans   # Delete local branches not on remote
```

**Enhanced Branch Cleanup** (with configurable protection):

```bash
# Two-stage safety pattern:
cleanbranches   # Preview what will be deleted
cleanorphans    # Actually delete the orphaned branches

# Customize protected branches and remote (in personal.sh):
export SKILLS_PROTECTED_BRANCHES="master main develop"  # Never delete these
export SKILLS_GIT_REMOTE="origin"                       # Remote to check against
```

### Development Tools

```bash
nocors     # Chrome without CORS restrictions
vers       # Show versions of dev tools
cvg        # Open test coverage report
gar        # Generate allure-report from allure-results in the current project
gar ../deployments/webapp-cvu
syncenv    # Append missing keys from .env.example to .env.local or .env
```

### Network Utilities

```bash
myip       # Display your public IP address

# Customize IP lookup endpoint (in personal.sh):
export SKILLS_MYIP_URL="https://checkip.amazonaws.com"  # Alternative IP service
```

### Environment Sync

```bash
syncenv                         # uses .env.example and prefers .env.local over .env
syncenv .env.example .env      # explicitly target .env
syncenv config/.env.sample .env.local
```

`syncenv` only appends keys that are missing from the target file. Existing local values are preserved.

### Testing

```bash
yt         # Run tests
ytc        # Run tests with coverage report
ytf        # Run tests, show only failures
yw <file>  # Run tests in watch mode for a file
# Add project-specific test runners in personal.sh
```

## 🔄 Migration from v1.x

If you're upgrading from the previous version:

1. **Automatic Backup**: Setup creates backups of your existing configs
2. **Guided Migration**: Interactive prompts help you through the process
3. **Backward Compatibility**: All your existing aliases continue to work
4. **New Features**: Gain access to enhanced documentation and modular structure

```bash
# Your existing setup will be preserved
./setup.sh  # Follow the prompts
go          # Reload and verify
```

## 🛠 Customization

### Adding New Commands

1. Edit the appropriate script in `scripts/` directory
2. Add your alias following the existing pattern:
   ```bash
   alias mycommand="echo 'Hello World'" # description
   ```
3. Run `go` to reload configurations

### Creating New Modules

1. Create a new `.sh` file in the `scripts/` directory
2. Add your functions and aliases
3. The setup automatically loads it on next `go` command

### Environment Variables

Available in all scripts:

- `$UserName` - Your username
- `$Workspace` - Your workspace path
- `$BashShells` - Path to this utility
- `$UserId` - Your org/employee ID (optional)
- `$CodeId` - Your GitHub username

## 🔒 Security & Best Practices

- **🔐 Personal Data**: Configuration files are git-ignored
- **💾 Automatic Backups**: Created before any modifications
- **🔍 No Sensitive Data**: Repository contains only templates
- **✅ Safe Permissions**: Proper file permission management
- **🛡️ Modular Design**: Easy to review and customize

## 📚 Documentation

- **[USAGE.md](USAGE.md)** - Complete command reference with examples
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and migration guides
- **[examples/](examples/)** - Common workflow scenarios
- **[config/](config/)** - Template configurations

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes thoroughly
4. **Update** documentation as needed
5. **Submit** a pull request

### Development Guidelines

- Follow existing code style and patterns
- Add comments explaining complex logic
- Test aliases in clean environment
- Update documentation for new features

For detailed contributing guidelines, see [CONTRIBUTING.md](.github/CONTRIBUTING.md).

## 🛠️ Development Setup (For Contributors)

### Install Development Tools

To ensure your contributions meet quality standards, install:

```bash
# ShellCheck — Static analysis tool for shell scripts
brew install shellcheck          # macOS
# or: sudo apt-get install shellcheck  # Linux

# shfmt — Shell script formatter (keeps formatting consistent)
brew install shfmt               # macOS
# or: GO111MODULE=on go install mvdan.cc/sh/v3/cmd/shfmt@latest  # Linux/any

# Lefthook — Git hooks manager (auto-runs checks on commit/push)
brew install lefthook            # macOS
# or: npm install -g @evilmartians/lefthook  # any OS
```

### Enable Automatic Checks

```bash
cd /path/to/webui-lib-shellscripts
lefthook install
```

After installation, git will automatically:

**On `git commit`:**

- ✅ Check shell script syntax
- ✅ Verify code formatting
- ✅ Run quick validation

**On `git push`:**

- ✅ Check all scripts comprehensively
- ✅ Verify full repository structure
- ✅ Scan for PII or hardcoded secrets

### Auto-Format Before Committing

```bash
# Format all shell scripts with 2-space indentation
shfmt -i 2 -w scripts/*.sh setup.sh validate.sh

# Format all markdown docs with Prettier (no install needed, runs via npx)
npx --yes prettier --write "**/*.md"
```

Or use our validation script:

```bash
./validate.sh                       # Check structure
shellcheck -x scripts/*.sh          # Check for issues
shfmt -d scripts/*.sh               # Check shell formatting
npx --yes prettier --check "**/*.md"  # Check markdown formatting
```

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for complete contributor workflow.

## 🆘 Troubleshooting

### Commands Not Found

- Run `go` to reload configurations
- Check if setup completed successfully: `which go`
- Verify scripts have execute permissions: `ls -la scripts/`

### Shell Compatibility Issues

- **"shopt: command not found"**: The script automatically detects bash/zsh and uses appropriate commands
- **"no matches found"**: This is fixed by proper glob pattern handling in the updated setup
- **Duplicate configurations**: Use `./setup.sh cleanup` to remove existing setup before reconfiguring

### Git Issues

- Verify git configuration: `git config --list`
- Check credentials are properly set
- Run `contrib` to test git access

### Path Issues

- Ensure workspace paths are correct in configuration
- Use absolute paths when in doubt
- Check `$Workspace` variable: `echo $Workspace`
- Prefer an ASCII-only symlink such as `~/alias-workspace` when your real path is inside iCloud or contains smart quotes

### Quick Verification (Cloud Paths)

After running setup, verify path-safe alias loading with:

- `echo "$Workspace"` (should print full path unchanged)
- `type app` (should show quoted-safe `cd "$Workspace"` behavior)
- `app` (should navigate correctly even with spaces/apostrophes)
- `go` (should reload aliases without errors)

### Setup Issues

- **Already configured**: The setup script now detects existing configurations and prevents duplicates
- **Permission denied**: Ensure the setup script has execute permissions: `chmod +x setup.sh`

## 📞 Support

- **📖 Documentation**: Check [USAGE.md](USAGE.md) for detailed command reference
- **🔍 Search**: Look through existing repository issues
- **🐛 Report Issues**: Create detailed issue reports with steps to reproduce
- **💡 Feature Requests**: Describe your use case and desired functionality

## 📈 What's Next

- Enhanced project detection and auto-configuration
- Additional development tool integrations
- Team-shared configuration templates
- Performance optimizations and caching
- Cross-platform compatibility improvements

---

**💡 Pro Tip**: Use `showme <keyword>` to discover commands - it's one of the most powerful features for exploring what's available!

**⭐ Star this repo** if it helps streamline your development workflow!

---

> **⚡ Quick Start**: Most developers are productive within 5 minutes of setup.

> **🔄 Always Evolving**: Regular updates based on team feedback and new workflow optimizations.
