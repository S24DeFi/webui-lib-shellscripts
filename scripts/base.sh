#!/usr/bin/env bash
# BASE UTILITIES
# Core aliases and functions for workspace navigation and common tasks
# This module provides essential navigation, file operations, and development shortcuts

# ============================================================================
# PROMPT CONFIGURATION
# ============================================================================

prompt_current_folder() {
    if [ "$PWD" = "$HOME" ]; then
        printf '~'
        return 0
    fi

    basename "$PWD"
}

prompt_git_branch() {
    local branch

    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
        branch=$(git rev-parse --short HEAD 2>/dev/null) ||
        return 0

    printf '%s' "$branch"
}

prompt_git_marker() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    if git status --porcelain --ignore-submodules=dirty 2>/dev/null | IFS= read -r _; then
        printf '*'
    fi
}

render_prompt() {
    local folder branch marker

    folder=$(prompt_current_folder)
    branch=$(prompt_git_branch)

    if [ -n "$branch" ]; then
        marker=$(prompt_git_marker)
        printf '%s [%s%s] > ' "$folder" "$branch" "$marker"
        return 0
    fi

    printf '%s > ' "$folder"
}

apply_shell_prompt() {
    if [ -n "$ZSH_VERSION" ]; then
        setopt PROMPT_SUBST 2>/dev/null
        # shellcheck disable=SC2034,SC2016 # PROMPT is read directly by zsh; single quotes are intentional (deferred expansion)
        PROMPT='$(render_prompt)'
        return 0
    fi

    PS1='$(render_prompt)'
    export PS1
}

# ============================================================================
# SHELL MANAGEMENT
# ============================================================================

unalias confirmmessage 2>/dev/null
unalias howmanyshells 2>/dev/null
unalias shells 2>/dev/null

shells() {
    # Primary: use the configured alias library path from setup.
    if [ -n "$BashShells" ] && [ -d "$BashShells" ]; then
        cd "$BashShells" || return 1
        return 0
    fi

    # Fallback: infer a likely folder in the workspace if config is missing.
    if [ -n "$Workspace" ] && [ -d "$Workspace/alias-webapp-lib" ]; then
        cd "$Workspace/alias-webapp-lib" || return 1
        return 0
    fi

    printf "shells: alias library path is not configured. Run setup and reload.\n" >&2
    return 1
}

count_aliases() {
    alias | wc -l | tr -d ' '
}

howmanyshells() {
    count_aliases
}

confirmmessage() {
    cls
    printf 'Setup complete: '
    whoami
    printf 'Bash sync confirmed\n= Shell Count => '
    howmanyshells
    apply_shell_prompt
}

go() {
    rc_file=

    if [ -n "$ZSH_VERSION" ] && [ -r "$HOME/.zshrc" ]; then
        rc_file="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ] && [ -r "$HOME/.bashrc" ]; then
        rc_file="$HOME/.bashrc"
    elif [ -r "$HOME/.zshrc" ]; then
        rc_file="$HOME/.zshrc"
    elif [ -r "$HOME/.bashrc" ]; then
        rc_file="$HOME/.bashrc"
    else
        printf "go: no readable shell rc file found in %s\n" "$HOME" >&2
        return 1
    fi

    # shellcheck disable=SC1090 # rc_file is dynamically .bashrc or .zshrc, resolved above
    . "$rc_file" && confirmmessage
}

# ============================================================================
# WORKSPACE NAVIGATION
# ============================================================================

alias app='cd "$Workspace" && ls' #navigate to workspace folder and list projects
alias cls='clear' #clear screen
alias desktop='cd ~/ && cd Desktop' #go to desktop
alias dk='desktop' #go to desktop
alias notes='app && cd notes && printf "Notes Loaded\n" && ls -ltra' #opens the defined notes folder
alias projects='app && ls -ltra' #show current projects in workspace

# ============================================================================
# GENERAL UTILITIES
# ============================================================================

alias detach='unalias -a && printf "aliases have been detached\n"' #detach current terminal from alias (use to ensure cleanup)
alias ew='open .' #open current directory in Finder (macOS)
alias vers='printf "NPM: " && npm --version && printf "Node: " && node --version && git --version && printf "Yarn: " && yarn --version && printf "NVM: " && nvm --version' #show versions
alias hashes='printf "#############################\n"' #comment line
alias savebash='cp ~/.bashrc saved-bash-latest.txt && printf "Bash saved\n" && ok' #shortcut used during initial configuration - see personal.sh to add shells navigation
alias savegit='cp ~/.gitconfig gitconfig-backup.txt && printf "Git config saved\n" && ok' #save git config to backup file - see personal.sh to add shells navigation

# ============================================================================
# WEB HELPERS
# ============================================================================

alias chromestore='trigger "https://chrome.google.com/webstore/category/extensions"' #open chrome extensions
alias clearhistory='history -c && printf "history has been cleared\n" && history && printf "\n"' #reset history
alias emoji='trigger https://gist.github.com/rxaviers/7360908' #opens the browser with emoji reference
alias flexboxhelp='trigger "https://css-tricks.com/snippets/css/a-guide-to-flexbox/"' #flexbox
alias fontawesomehelp='trigger "https://fontawesome.com/icons?d=gallery"' #trigger fa
alias mdhelp='trigger https://confluence.atlassian.com/bitbucketserver/markdown-syntax-guide-776639995.html' #comment
alias shellhelp='trigger https://www.shellscript.sh/' #launch the DOCS on shellscripts
alias vimhelp='trigger https://vim.rtorr.com' #vim helper comment
alias orm='open README.md' #open readme.md in default app (macOS: override in personal.sh to set a specific app)

# ============================================================================
# FILE OPERATIONS
# ============================================================================

alias countfiles='ls -l | grep -v ^l | wc -l' #count files
alias list='alias' #shortcut for alias
alias lsF='typeset -f' #list all functional aliases
alias lsf='typeset -F' #list all non function aliases
alias llt='ls -la' #show current projects with detailed listing in alphabetical order
alias ok='ls -la && printf "File count:" && countfiles' #list files
alias grabvids='printf "Moved all videos to current folder\n" && mv ~/Desktop/*Rec* .' #grabs all screen recording video files and add them to the current folder
alias working='cat | gd > ~/Desktop/lastdiff.txt && cd ~/Desktop && start lastdiff.txt' #last - create a list of current changes

# ============================================================================
# SCREENSHOT UTILITIES
# ============================================================================

alias grabshots='printf "Moved files to new folder\n" && mv ~/Desktop/Scre* .' #grabs all screenshot files from the desktop and drops them in the current folder
alias mvshots='desktop && mv Scre* ../_screenshots && printf "Screenshots moved to updated image folder\n"' #comment
alias shots='printf "Image Listing for Screenshots\n" && ls -ltra ~/Desktop/Sc*' #prints a list all screenshots on the desktop
alias gs='grabshots' #shortcut for grabshots

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================

alias cvg='trigger coverage/lcov-report/index.html' #launch coverage report for a project
alias nocors='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security' #open non coors browser

# ============================================================================
# GIT COMMANDS
# ============================================================================

# Configuration (optional, can be set in personal.sh or parent shell):
#   SKILLS_GIT_REMOTE — remote to check against (default: origin)
#   SKILLS_PROTECTED_BRANCHES — space-separated branch names never deleted (default: master main)

SKILLS_GIT_REMOTE="${SKILLS_GIT_REMOTE:-origin}"

_git_list_local_branches() {
    git for-each-ref refs/heads/ --format='%(refname:short)' 2>/dev/null
}

_git_is_protected() {
    local branch="$1"
    local tok
    # Iterate through protected branches (default: master main)
    for tok in ${SKILLS_PROTECTED_BRANCHES:-master main}; do
        [ -z "$tok" ] && continue
        [ "$branch" = "$tok" ] && return 0
    done
    return 1
}

unalias cleanbranches 2>/dev/null
cleanbranches() {
    local remote current_branch total_orphaned gone_branches
    remote="$SKILLS_GIT_REMOTE"

    git fetch --prune
    printf 'Checking for branches to clean up...\n'

    # Clean up branches marked as [gone] (tracked branches deleted from remote)
    gone_branches=$(git branch -vv 2>/dev/null | grep '\[gone\]' | awk '{print $1}' || true)
    if [ -n "$gone_branches" ]; then
        echo "$gone_branches" | xargs git branch -D
        printf 'Cleaned up tracked branches that were deleted from remote\n'
    fi

    current_branch=$(git branch --show-current)

    # List orphaned branches (preview)
    while IFS= read -r branch; do
        [ -z "$branch" ] && continue
        if [ "$branch" = "$current_branch" ]; then
            continue
        fi
        if _git_is_protected "$branch"; then
            continue
        fi
        if ! git ls-remote --heads "$remote" "refs/heads/$branch" 2>/dev/null | grep -q "$branch"; then
            printf '  Orphaned: %s\n' "$branch"
        fi
    done < <(_git_list_local_branches)

    # Count total orphaned branches
    total_orphaned=0
    while IFS= read -r branch; do
        [ -z "$branch" ] && continue
        if [ "$branch" = "$current_branch" ]; then
            continue
        fi
        if _git_is_protected "$branch"; then
            continue
        fi
        if ! git ls-remote --heads "$remote" "refs/heads/$branch" 2>/dev/null | grep -q "$branch"; then
            total_orphaned=$((total_orphaned + 1))
        fi
    done < <(_git_list_local_branches)

    if [ "$total_orphaned" -gt 0 ]; then
        printf '\nFound %d local branch(es) not on remote %s.\n' "$total_orphaned" "$remote"
        printf 'Run "cleanorphans" to delete them.\n'
    else
        printf 'No orphaned branches found.\n'
    fi
}

unalias cleanorphans 2>/dev/null
cleanorphans() {
    local remote current_branch
    remote="$SKILLS_GIT_REMOTE"
    current_branch=$(git branch --show-current)

    while IFS= read -r branch; do
        [ -z "$branch" ] && continue
        if [ "$branch" = "$current_branch" ]; then
            continue
        fi
        if _git_is_protected "$branch"; then
            continue
        fi
        if ! git ls-remote --heads "$remote" "refs/heads/$branch" 2>/dev/null | grep -q "$branch"; then
            git branch -D "$branch" && printf 'Deleted: %s\n' "$branch"
        fi
    done < <(_git_list_local_branches)

    printf 'Orphaned branches cleanup complete\n'
}

# Delete finished local branches that cleanbranches/cleanorphans keep because
# the remote branch still exists: merged or squash-merged into the default
# branch, or fully pushed with a merged/closed PR (needs gh).
# Usage: cleanlocalbranches [-y]   (-y skips the confirmation prompt)
unalias cleanlocalbranches 2>/dev/null
cleanlocalbranches() {
    local remote base current_branch branch upstream worktree reason states mb tmp doomed count reply
    remote="$SKILLS_GIT_REMOTE"

    git fetch --prune "$remote" || return 1

    # Default branch on the remote (origin/main, origin/master, ...)
    base=$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null)
    if [ -z "$base" ]; then
        for branch in main master; do
            if git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
                base="$remote/$branch"
                break
            fi
        done
    fi
    if [ -z "$base" ]; then
        printf 'Could not determine the default branch of %s\n' "$remote"
        return 1
    fi

    current_branch=$(git branch --show-current)
    doomed=""
    count=0

    while IFS='|' read -r branch upstream worktree; do
        [ -z "$branch" ] && continue
        # Skip current, protected, default, and anything checked out in a worktree
        [ "$branch" = "$current_branch" ] && continue
        [ "$branch" = "${base#"$remote"/}" ] && continue
        [ -n "$worktree" ] && continue
        if _git_is_protected "$branch"; then
            continue
        fi

        reason=""
        if git merge-base --is-ancestor "$branch" "$base" 2>/dev/null; then
            reason="merged into $base"
        else
            # Squash merge: the branch's combined diff already exists as one commit on base
            mb=$(git merge-base "$base" "$branch" 2>/dev/null)
            if [ -n "$mb" ]; then
                tmp=$(git commit-tree "$branch^{tree}" -p "$mb" -m _ 2>/dev/null)
                case "$(git cherry "$base" "$tmp" 2>/dev/null)" in
                    -*) reason="squash-merged into $base" ;;
                esac
            fi
        fi

        # Still on the remote with nothing unpushed: safe to drop once its PR is no longer open
        if [ -z "$reason" ] && [ -n "$upstream" ] && command -v gh >/dev/null 2>&1 \
            && git show-ref --verify --quiet "refs/remotes/$upstream" \
            && [ "$(git rev-list --count "$upstream..$branch" 2>/dev/null)" = "0" ]; then
            states=$(gh pr list --head "$branch" --state all --json state --jq '.[].state' </dev/null 2>/dev/null)
            case "$states" in
                *OPEN*) ;;
                *MERGED*) reason="PR merged, still on $remote" ;;
                *CLOSED*) reason="PR closed, still on $remote" ;;
            esac
        fi

        if [ -n "$reason" ]; then
            printf '  %s  (%s)\n' "$branch" "$reason"
            doomed="${doomed}${branch}
"
            count=$((count + 1))
        fi
    done < <(git for-each-ref refs/heads/ --format='%(refname:short)|%(upstream:short)|%(worktreepath)' 2>/dev/null)

    if [ "$count" -eq 0 ]; then
        printf 'No finished local branches found.\n'
        return 0
    fi

    if [ "$1" != "-y" ]; then
        printf '\nDelete these %d local branch(es)? [y/N] ' "$count"
        read -r reply
        case "$reply" in
            y|Y|yes) ;;
            *) printf 'Nothing deleted.\n'; return 0 ;;
        esac
    fi

    while IFS= read -r branch; do
        [ -z "$branch" ] && continue
        git branch -D "$branch" >/dev/null && printf 'Deleted: %s\n' "$branch"
    done <<EOF
$doomed
EOF
}

# Existing git aliases (names preserved)
alias cleanprune='git config --get-all branch.master.remote' #config clean up prune
alias gbr='git br' #git branch info
alias gcom='git fetch && git checkout master && git pull && git bv' #checkout and update master - show results
alias gmm='git merge master' #pull in master branch
alias gsl='git stash list' #list stashes
alias gls='git stash list' #list the stashes
alias gpod='yb && git push origin HEAD --no-verify' #push master branch
alias grpo='git remote prune origin' #remove local branches not on remote
alias msg='git bv && hashes && git s && git ld -3 && hashes && hashes && git r' #show my git status
alias tags='git tag' #show tag info
alias gfom='git fetch origin && msg' #fetch origin master and show git status
alias gfmsg='git fetch && msg' #fetch and show git status
alias gfm='git fetch && msg' #fetch and show git status (alternate)
alias grh='git reset --hard' #git reset hard (use with caution)

# Set upstream for current branch to origin (fix branch tracking error)
unalias sub 2>/dev/null
sub() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    git branch --set-upstream-to="origin/$branch" "$branch"
}

# ============================================================================
# YARN COMMANDS
# ============================================================================

alias ya='yarn audit' #check the status of yarn packages
alias yb='yarn build' #local yarn build
alias ycuui='yarn check-updates -u -i' #check for yarn updates interactively
alias yd='yarn dev' #run yarn in dev mode
alias yl='yarn lint' #local yarn lint
alias yt='yarn test' #local yarn test
alias yta='yarn test -o --bail --watch' #local yarn test with watch flag
alias ytc='yarn test:coverage && cvg' #local yarn test and opens the coverage report
alias ytcn='yarn test:coverage' #local yarn test but does NOT open the coverage report
alias ytu='yarn test -u' #local yarn test - updating screenshots
alias ytf="yarn test 2>&1 | grep -E '^FAIL |^Test Suites:'" #local yarn test - only show failed tests

# ============================================================================
# NETWORK / MACHINE HELPERS
# ============================================================================

alias mynetip='ipconfig getifaddr en0' #get network ip

# ============================================================================
# PROJECT HUB ACTIVATION
# ============================================================================
# Initialize a project with modular shell configuration and AI skills folder
# Usage: activate-hub
# Creates: .shell-config (project shell initialization)
#          skills/ (folder for project AI agent instructions)
#          skills/<PROJECT>.md (boilerplate skill template)

activate-hub() {
    local project_name project_dir shell_config skills_dir skill_file
    local webui_lib_path

    project_dir="$(pwd)"
    project_name="$(basename "$project_dir")"

    # Determine path to webui-lib-shellscripts
    # Try common locations: BashShells, sibling dir, Workspace parent, or ~/.local
    if [ -n "$BashShells" ] && [ -f "$BashShells/scripts/hub.sh" ]; then
        webui_lib_path="$BashShells"
    elif [ -f "../webui-lib-shellscripts/scripts/hub.sh" ]; then
        webui_lib_path="$(cd ../webui-lib-shellscripts && pwd)"
    elif [ -n "$Workspace" ] && [ -f "$Workspace/webui-lib-shellscripts/scripts/hub.sh" ]; then
        webui_lib_path="$Workspace/webui-lib-shellscripts"
    elif [ -f "$HOME/.local/webui-lib-shellscripts/scripts/hub.sh" ]; then
        webui_lib_path="$HOME/.local/webui-lib-shellscripts"
    else
        printf "[activate-hub] Error: Cannot locate webui-lib-shellscripts\n" >&2
        printf "[activate-hub] Try: cd .. && ls webui-lib-shellscripts/scripts/hub.sh\n" >&2
        return 1
    fi

    shell_config="$project_dir/.shell-config"
    skills_dir="$project_dir/skills"
    skill_file="$skills_dir/${project_name}.md"

    printf "Activating project hub for: %s\n" "$project_name"
    printf "  Using webui-lib-shellscripts at: %s\n" "$webui_lib_path"

    # Create .shell-config if missing
    if [ ! -f "$shell_config" ]; then
        printf "Creating .shell-config...\n"
        cat > "$shell_config" << 'EOF'
#!/bin/sh
# Project Shell Configuration
# Load core utilities and define project-specific settings
# Usage: source .shell-config (or: . .shell-config)
# POSIX-compatible: works in sh, bash, zsh

# Load core utilities unless the hub is already loaded in this shell
if [ -z "${SKILLS_ROOT:-}" ]; then
	# Detect WEBUI_LIB_PATH (POSIX-compatible, no bash-isms)
	if [ -z "${WEBUI_LIB_PATH:-}" ]; then
		# Try sibling directory (canonical location in Developer workspace)
		_script_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || true
		if [ -f "${_script_dir}/../webui-lib-shellscripts/scripts/hub.sh" ]; then
			WEBUI_LIB_PATH="${_script_dir}/../webui-lib-shellscripts"
		elif [ -f "$HOME/Developer/webui-lib-shellscripts/scripts/hub.sh" ]; then
			WEBUI_LIB_PATH="$HOME/Developer/webui-lib-shellscripts"
		elif [ -f "$HOME/.local/webui-lib-shellscripts/scripts/hub.sh" ]; then
			WEBUI_LIB_PATH="$HOME/.local/webui-lib-shellscripts"
		fi
		unset _script_dir
	fi

	if [ ! -f "$WEBUI_LIB_PATH/scripts/hub.sh" ]; then
		printf "[.shell-config] Error: Cannot find hub.sh at %s\n" "$WEBUI_LIB_PATH" >&2
		printf "[.shell-config] Set WEBUI_LIB_PATH to the correct path and try again\n" >&2
		return 1
	fi

	# Load all core utilities (git, network, automation, etc.)
	. "$WEBUI_LIB_PATH/scripts/hub.sh"
fi

# ============================================================================
# PROJECT ALIASES — quick template, uncomment or add your own below
# ============================================================================
# Pattern: alias <name>='<command>' #what it does
# PROJECT_NAME="$(basename "$PWD")"
# alias build='yarn build' #build the project
# alias test='yarn test --watch' #run tests in watch mode
# alias serve='yarn dev' #start the dev server
#
# Need arguments? Use a function instead:
# deploy() { yarn deploy "${1:-staging}"; }
#
# Navigation to this project from anywhere lives in personal.sh — run
# project-shell to register it (e.g. alias myproject='app && cd myproject')

printf "✓ Project hub activated: %s\n" "$(basename "$PWD")"
EOF
        chmod +x "$shell_config"
        printf "  Created: %s\n" "$shell_config"
    else
        printf "  .shell-config already exists\n"
    fi

    # Create skills directory if missing
    if [ ! -d "$skills_dir" ]; then
        mkdir -p "$skills_dir"
        printf "Created skills directory...\n"
        printf "  Created: %s/\n" "$skills_dir"
    else
        printf "  %s/ already exists\n" "$skills_dir"
    fi

    # Create base skill template if missing
    if [ ! -f "$skill_file" ]; then
        printf "Creating base skill template...\n"
        cat > "$skill_file" << 'SKILLEOF'
---
applyTo:
  - filePaths: []
  - fileNames:
      - "*.md"
      - "*.ts"
      - "*.tsx"
      - "*.js"
      - "*.jsx"
      - "*.py"
      - "*.sh"
---

# PROJECT Skills and Agent Configuration

This folder contains AI agent instructions, custom skills, and domain-specific knowledge for this project.

## Folder Structure

```
skills/
├── PROJECT.md              # Main project skills (this file)
├── [feature-name].md       # Feature-specific agent instructions
├── [module-name].md        # Module-specific context
└── [AGENT-NAME].md         # Custom agents for specialized workflows
```

## What Goes Here

Use these files to document:
- Project structure and conventions
- Development workflows
- Coding patterns
- AI context
- Tool integrations
- Custom agents

## Getting Started

1. Define your project fundamentals in this file
2. Create feature-specific skills as needed
3. Use `source .shell-config` to activate project utilities
4. Share `skills/` with team members for consistent AI assistance
SKILLEOF
        printf "  Created: %s\n" "$skill_file"
    else
        printf "  %s already exists\n" "$skill_file"
    fi

    printf "\nProject hub initialized successfully!\n"
    printf "\nNext steps:\n"
    printf "  1. source .shell-config          # Activate utilities for this project\n"
    printf "  2. Edit skills/%s.md           # Customize AI agent instructions\n" "$(basename "$project_dir")"
    printf "  3. showme help                   # Discover available commands\n"
    printf "\nTo activate in future sessions:\n"
    printf "  cd %s && source .shell-config\n" "$project_name"
}

# ============================================================================
# Check the current project for a project-specific shell, create it if missing,
# and register a navigation alias for the project
# Usage: project-shell [alias-name]   (alias name defaults to the project folder)
# Checks:  .shell-config at the project root (git root, else current directory)
# Creates: .shell-config + skills/ via activate-hub when missing
#          alias <name>='app && cd <project>' in personal.sh (available everywhere)

project-shell() {
    local project_dir project_name alias_name nav_cmd personal_file

    project_dir="$(git rev-parse --show-toplevel 2>/dev/null)" || project_dir="$(pwd)"
    project_name="$(basename "$project_dir")"
    alias_name="${1:-$project_name}"

    case "$alias_name" in
        "" | *[!A-Za-z0-9_.-]*)
            printf "[project-shell] Error: '%s' is not a usable alias name\n" "$alias_name" >&2
            printf "Usage: project-shell [alias-name]\n" >&2
            return 1
            ;;
    esac

    case "$project_dir" in
        *[\'\"\$\`\\]*)
            printf "[project-shell] Error: project path has characters that cannot be aliased safely: %s\n" "$project_dir" >&2
            return 1
            ;;
    esac

    # Project shell: report it, or scaffold it with activate-hub
    if [ -f "$project_dir/.shell-config" ]; then
        printf "Project shell already in place: %s\n" "$project_dir/.shell-config"
    else
        printf "No project shell found for %s — creating one\n" "$project_name"
        (cd "$project_dir" && activate-hub) || return 1
    fi

    # Navigation alias: goes through `app` when the project sits in $Workspace
    if [ -n "$Workspace" ] && [ "$project_dir" = "${Workspace%/}/$project_name" ]; then
        nav_cmd="app && cd \"$project_name\""
    else
        nav_cmd="cd \"$project_dir\""
    fi

    if [ -n "$BashShells" ] && [ -d "$BashShells/scripts" ]; then
        personal_file="$BashShells/scripts/personal.sh"
    elif [ -n "$SKILLS_ROOT" ] && [ -d "$SKILLS_ROOT" ]; then
        personal_file="$SKILLS_ROOT/personal.sh"
    else
        personal_file=""
    fi

    if [ -n "$personal_file" ] && [ -f "$personal_file" ] && grep -qF "alias ${alias_name}=" "$personal_file"; then
        printf "Navigation alias already in place: %s\n" "$alias_name"
    elif command -v "$alias_name" > /dev/null 2>&1; then
        printf "[project-shell] '%s' is already a command — skipping the navigation alias\n" "$alias_name" >&2
        printf "[project-shell] Pick another name: project-shell <alias-name>\n" >&2
    elif [ -z "$personal_file" ]; then
        # shellcheck disable=SC2139 # expanding nav_cmd now is intended
        alias "$alias_name=$nav_cmd"
        printf "Navigation alias set for this session only (alias library path is not configured): %s\n" "$alias_name"
    else
        [ -f "$personal_file" ] || printf '#!/bin/sh\n# personal.sh — Personal, gitignored utilities and machine-specific overrides.\n' > "$personal_file"
        # Keep appended lines off the end of an unterminated last line
        [ -z "$(tail -c 1 "$personal_file")" ] || printf '\n' >> "$personal_file"
        if ! grep -qF "# PROJECT NAVIGATION (managed by project-shell)" "$personal_file"; then
            {
                printf '\n# ============================================================================\n'
                printf '# PROJECT NAVIGATION (managed by project-shell)\n'
                printf '# ============================================================================\n'
            } >> "$personal_file"
        fi
        printf "alias %s='%s' #navigate to the %s project\n" "$alias_name" "$nav_cmd" "$project_name" >> "$personal_file"
        # shellcheck disable=SC2139 # expanding nav_cmd now is intended
        alias "$alias_name=$nav_cmd"
        printf "Navigation alias added: %s => %s\n" "$alias_name" "$nav_cmd"
        printf "  Saved to: %s\n" "$personal_file"
    fi

    # Load the project's own aliases into this shell
    # shellcheck disable=SC1091 # project file, resolved at runtime
    . "$project_dir/.shell-config"
}

apply_shell_prompt
