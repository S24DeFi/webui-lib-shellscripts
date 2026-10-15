#!/bin/sh
# shellcheck shell=bash
# AUTOMATION FUNCTIONS
# Workflow automation and interactive functions for development tasks
# This module provides enhanced git workflows, PR navigation, and test runners
# Note: uses 'local' (a bash/zsh/dash extension); always sourced into bash/zsh,
# never executed directly under strict POSIX sh.

# ============================================================================
# BRANCH WORKFLOW
# ============================================================================

# Enhanced newbranch function for branch creation workflow
# Usage: newbranch
# Interactively prompts for branch type, project, ticket, and summary
newbranch() {
	# Prompt for TYPE
	echo "Select branch TYPE:"
	echo "1) bug"
	echo "2) defect"
	echo "3) spike"
	echo "4) feature"
	echo "5) debt"
	printf "Enter number (1-5): "
	read -r TYPE_NUM
	case "$TYPE_NUM" in
		1) TYPE="bugfix" ;;
		2) TYPE="defect" ;;
		3) TYPE="spike" ;;
		4) TYPE="feature" ;;
		5) TYPE="techdebt" ;;
		*)
			echo "Invalid selection." >&2
			return 1
			;;
	esac

	printf "Enter project name: "
	read -r PROJECT
	if [ -z "$PROJECT" ]; then
		echo "Project name required." >&2
		return 1
	fi

	printf "Enter ticket number: "
	read -r TICKET
	if [ -z "$TICKET" ]; then
		echo "Ticket number required." >&2
		return 1
	fi

	printf "Enter branch summary (multiple words): "
	read -r SUMMARY
	if [ -z "$SUMMARY" ]; then
		echo "Summary required." >&2
		return 1
	fi

	SUMMARY_HYPHENATED=$(echo "$SUMMARY" | tr ' ' '-')
	BRANCH_NAME="${TYPE}/${PROJECT}-${TICKET}/${SUMMARY_HYPHENATED}"

	# Validate branch name
	if ! git check-ref-format --branch "$BRANCH_NAME"; then
		echo "Invalid branch name: $BRANCH_NAME" >&2
		return 1
	fi

	# Check if branch already exists
	if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
		echo "Branch already exists: $BRANCH_NAME" >&2
		printf "Switch to it? (y/n): "
		read -r SWITCH
		if [ "$SWITCH" = "y" ] || [ "$SWITCH" = "Y" ]; then
			git checkout "$BRANCH_NAME"
			return 0
		else
			return 1
		fi
	fi

	if git branch "$BRANCH_NAME" && git checkout "$BRANCH_NAME"; then
		printf "New branch created: %s\n" "$BRANCH_NAME"
		if command -v hashes >/dev/null 2>&1; then
			hashes
		fi
		return 0
	else
		echo "Failed to create branch: $BRANCH_NAME" >&2
		return 1
	fi
}

# ============================================================================
# ANALYSIS HELPERS
# ============================================================================

# List changed files for SonarQube analysis
# Usage: sonarcheck
# This command lists all changed files and prompts you to request SonarQube analysis via Copilot
sonarcheck() {
	echo "==================================="
	echo "SonarQube Quality Check"
	echo "==================================="
	echo ""

	# Get list of changed files (both staged and unstaged)
	CHANGED_FILES=$(git diff --name-only HEAD && git diff --name-only --cached)

	if [ -z "$CHANGED_FILES" ]; then
		echo "No changed files found."
		echo ""
		echo "Run 'git status' to verify your changes."
		return 0
	fi

	echo "Changed files requiring analysis:"
	echo ""
	echo "$CHANGED_FILES" | while read -r file; do
		if [ -n "$file" ] && [ -f "$file" ]; then
			echo "  • $file"
		fi
	done

	echo ""
	echo "==================================="
	echo "Next Steps:"
	echo "==================================="
	echo "1. Copy the file paths above"
	echo "2. Ask Copilot to analyze them:"
	echo "   'Run SonarQube analysis on these files'"
	echo ""
	echo "Or use the /prReady prompt for full validation"
	echo ""
}

# ============================================================================
# SERVER MANAGEMENT
# ============================================================================

# Kill process listening on a TCP port
# Usage: stopserver <port>
stopserver() {
	if [ -z "$1" ]; then
		echo "Usage: stopserver <port>" >&2
		echo "Example: stopserver 8000" >&2
		return 1
	fi

	port="$1"
	case "$port" in
		*[!0-9]*)
			echo "Error: port must be a number (got: $port)" >&2
			return 1
			;;
	esac

	if ! command -v lsof >/dev/null 2>&1; then
		echo "Error: lsof not found" >&2
		return 1
	fi

	pids=$(lsof -nP -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null)
	if [ -z "$pids" ]; then
		echo "No process listening on port $port"
		return 0
	fi

	echo "Killing PID(s) on port $port: $pids"
	# shellcheck disable=SC2086 # intentional word-splitting: pids may contain multiple space/newline-separated PIDs
	kill -9 $pids
}

# ============================================================================
# ENVIRONMENT SYNC
# ============================================================================

# Parse a KEY from a .env-style assignment line
# Usage: _syncenv_parse_key "KEY=value"
_syncenv_parse_key() {
	if [ -z "$1" ]; then
		return 1
	fi

	printf '%s\n' "$1" | awk '
		{
			line = $0
			sub(/^[[:space:]]+/, "", line)

			if (line == "" || substr(line, 1, 1) == "#") {
				next
			}

			sub(/^export[[:space:]]+/, "", line)

			if (match(line, /^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/)) {
				key = substr(line, RSTART, RLENGTH)
				sub(/[[:space:]]*=$/, "", key)
				print key
			}
		}
	'
}

# Print all defined keys from a .env-style file
# Usage: _syncenv_collect_keys <env_file>
_syncenv_collect_keys() {
	local line key

	if [ ! -f "$1" ]; then
		return 1
	fi

	while IFS= read -r line || [ -n "$line" ]; do
		key=$(_syncenv_parse_key "$line")
		if [ -n "$key" ]; then
			printf '%s\n' "$key"
		fi
	done < "$1"
}

# Append missing env variables from an example file into a local env file
# Usage: syncenv [example_file] [target_file]
syncenv() {
	local example_file target_file existing_keys_file missing_lines_file missing_keys_file
	local line key added_count

	example_file="${1:-.env.example}"
	target_file="${2:-}"

	if [ ! -f "$example_file" ]; then
		echo "Error: example file not found: $example_file" >&2
		return 1
	fi

	if [ -z "$target_file" ]; then
		if [ -f ".env.local" ]; then
			target_file=".env.local"
		elif [ -f ".env" ]; then
			target_file=".env"
		else
			echo "Error: no target env file found. Create .env.local or .env, or pass a target file." >&2
			return 1
		fi
	elif [ ! -f "$target_file" ]; then
		echo "Error: target file not found: $target_file" >&2
		return 1
	fi

	existing_keys_file="$(mktemp)" || {
		echo "Error: failed to create temporary file." >&2
		return 1
	}
	missing_lines_file="$(mktemp)" || {
		rm -f "$existing_keys_file"
		echo "Error: failed to create temporary file." >&2
		return 1
	}
	missing_keys_file="$(mktemp)" || {
		rm -f "$existing_keys_file" "$missing_lines_file"
		echo "Error: failed to create temporary file." >&2
		return 1
	}

	if ! _syncenv_collect_keys "$target_file" > "$existing_keys_file"; then
		rm -f "$existing_keys_file" "$missing_lines_file" "$missing_keys_file"
		echo "Error: failed to read target file: $target_file" >&2
		return 1
	fi

	while IFS= read -r line || [ -n "$line" ]; do
		key=$(_syncenv_parse_key "$line")
		if [ -n "$key" ] && ! grep -Fqx "$key" "$existing_keys_file"; then
			printf '%s\n' "$line" >> "$missing_lines_file"
			printf '%s\n' "$key" >> "$missing_keys_file"
		fi
	done < "$example_file"

	if [ ! -s "$missing_lines_file" ]; then
		rm -f "$existing_keys_file" "$missing_lines_file" "$missing_keys_file"
		echo "No missing variables. $target_file already includes all keys from $example_file."
		return 0
	fi

	{
		printf '\n# Added by syncenv from %s\n' "$example_file"
		cat "$missing_lines_file"
	} >> "$target_file" || {
		rm -f "$existing_keys_file" "$missing_lines_file" "$missing_keys_file"
		echo "Error: failed to update target file: $target_file" >&2
		return 1
	}

	added_count="$(wc -l < "$missing_keys_file" | tr -d ' ')"

	echo "Added $added_count missing variable(s) to $target_file:"
	while IFS= read -r key || [ -n "$key" ]; do
		if [ -n "$key" ]; then
			printf '  - %s\n' "$key"
		fi
	done < "$missing_keys_file"

	rm -f "$existing_keys_file" "$missing_lines_file" "$missing_keys_file"
}

# ============================================================================
# REPORTING / ALLURE
# ============================================================================

unalias gar 2>/dev/null
gare() {
	local project_dir results_dir report_dir abs_report_dir

	project_dir="${1:-.}"
	results_dir="${2:-allure-results}"
	report_dir="${3:-allure-report}"

	if ! command -v allure >/dev/null 2>&1; then
		echo "Error: allure command not found" >&2
		return 1
	fi

	if [ ! -d "$project_dir" ]; then
		echo "Error: project directory not found: $project_dir" >&2
		return 1
	fi

	if [ ! -d "$project_dir/$results_dir" ]; then
		echo "Error: allure results directory not found: $project_dir/$results_dir" >&2
		return 1
	fi

	if ! (
		cd "$project_dir" &&
		allure generate "$results_dir" --output "$report_dir"
	); then
		return 1
	fi

	abs_report_dir="$(cd "$project_dir/$report_dir" 2>/dev/null && pwd)"
	if [ -n "$abs_report_dir" ]; then
		printf 'Allure report generated: %s\n' "$abs_report_dir"
	else
		printf 'Allure report generated in %s/%s\n' "$project_dir" "$report_dir"
	fi
}

alias gar='gare' # generate allure-report from allure-results (supports: gar [project_dir] [results_dir] [report_dir])
alias oar='allure open allure-report' #open allure report
alias oct='open reports/cucumber-report.html' #open cucumber report

# ============================================================================
# MISC AUTOMATION / INTEGRATIONS
# ============================================================================

alias cfe='printf "Drinking coffee\n *>\n" && caffeinate -d' #run coffee
alias gafe='gitnexus analyze --force --embeddings' #runs the git nexus analyze script with flags
