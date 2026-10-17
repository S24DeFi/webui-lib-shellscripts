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

# Refresh a Claude Code plugin marketplace and every plugin installed from it
# Usage: updateskills [marketplace]   (default: andre-skills)
updateskills() {
	local marketplace plugins plugin failed

	marketplace="${1:-andre-skills}"
	failed=0

	if ! command -v claude >/dev/null 2>&1; then
		echo "Error: claude command not found" >&2
		return 1
	fi

	if ! claude plugin marketplace update "$marketplace"; then
		echo "Error: failed to update marketplace: $marketplace" >&2
		return 1
	fi

	plugins=$(claude plugin list 2>/dev/null | grep -o "[A-Za-z0-9_-]*@${marketplace}" | sort -u)
	if [ -z "$plugins" ]; then
		echo "No plugins installed from $marketplace."
		echo "Install one with: claude plugin install <team>@$marketplace"
		return 0
	fi

	# read line-by-line: zsh does not word-split unquoted variables
	while IFS= read -r plugin; do
		claude plugin update "$plugin" </dev/null || failed=1
	done <<EOF
$plugins
EOF

	if [ "$failed" -ne 0 ]; then
		echo "Error: one or more plugins failed to update" >&2
		return 1
	fi

	echo "Skills updated. Restart Claude Code to load the new versions."
}

# Symlink skills from ~/.agents/skills (Cursor/ChatGPT) into ~/.claude/skills
# Skips names Claude already has and prunes links whose agents skill was removed
# Usage: syncskills [-n]   (-n: dry run, only list what is missing)
# Env: AGENTS_SKILLS_DIR, CLAUDE_SKILLS_DIR override the default folders
#      SKILLS_SYNC_IGNORE — space-separated skill names never linked
#      (default: Cursor/Codex-only skills and names that clash with Claude built-ins)
SKILLS_SYNC_IGNORE="${SKILLS_SYNC_IGNORE:-update-cursor-settings create-rule migrate-to-skills \
canvas create-hook create-skill create-subagent loop new-repo onboard origin rename-chat \
sdk share statusline update-cli-config review review-bugbot review-security automate goal shell}"
syncskills() {
	local src dest dry_run skill name target linked missing pruned

	src="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
	dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
	dry_run=0
	linked=0
	missing=0
	pruned=0

	case "${1:-}" in
	-n | --dry-run | --list) dry_run=1 ;;
	"") ;;
	*)
		echo "Usage: syncskills [-n]" >&2
		return 1
		;;
	esac

	if [ ! -d "$src" ]; then
		echo "Error: agents skills folder not found: $src" >&2
		return 1
	fi
	mkdir -p "$dest" || return 1

	# find instead of a glob: zsh errors on globs that match nothing
	while IFS= read -r skill; do
		[ -f "$skill/SKILL.md" ] || continue
		name="$(basename "$skill")"
		# padded match: zsh does not word-split unquoted variables
		case " $SKILLS_SYNC_IGNORE " in
		*" $name "*) continue ;;
		esac
		if [ -e "$dest/$name" ] || [ -L "$dest/$name" ]; then
			continue
		fi
		missing=$((missing + 1))
		if [ "$dry_run" -eq 1 ]; then
			printf '  missing: %s\n' "$name"
		elif ln -s "$skill" "$dest/$name"; then
			printf '  linked:  %s\n' "$name"
			linked=$((linked + 1))
		fi
	done <<EOF
$(find "$src" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) | sort)
EOF

	# Remove dangling links that pointed into the agents folder
	while IFS= read -r skill; do
		[ -n "$skill" ] || continue
		[ -e "$skill" ] && continue
		target="$(readlink "$skill")"
		case "$target" in
		"$src"/*) ;;
		*) continue ;;
		esac
		if [ "$dry_run" -eq 1 ]; then
			printf '  stale:   %s\n' "$(basename "$skill")"
		elif rm "$skill"; then
			printf '  pruned:  %s\n' "$(basename "$skill")"
			pruned=$((pruned + 1))
		fi
	done <<EOF
$(find "$dest" -mindepth 1 -maxdepth 1 -type l)
EOF

	if [ "$dry_run" -eq 1 ]; then
		printf '%d skill(s) in %s not available to Claude. Run syncskills to link them.\n' "$missing" "$src"
	else
		printf 'Linked %d, pruned %d. Restart Claude Code to load new skills.\n' "$linked" "$pruned"
	fi
}

alias missingskills='syncskills -n' #list ~/.agents skills Claude Code cannot see

# Print "source<TAB>folder" for every skill folder that exists on this machine
# Env: SKILLS_EXTRA_DIRS — extra "source:path" pairs, space-separated
_skill_roots() {
	local pair label dir manifest

	for pair in \
		"claude:$HOME/.claude/skills" \
		"agents:$HOME/.agents/skills" \
		"codex:$HOME/.codex/skills" \
		"cursor:$HOME/.cursor/skills" \
		"cursor:$HOME/.cursor/skills-cursor" \
		"project:$PWD/.claude/skills" \
		"project:$PWD/.agents/skills"; do
		label="${pair%%:*}"
		dir="${pair#*:}"
		[ -d "$dir" ] && printf '%s\t%s\n' "$label" "$dir"
	done

	# padded loop input: zsh does not word-split unquoted variables
	printf '%s\n' "${SKILLS_EXTRA_DIRS:-}" | tr ' ' '\n' | while IFS= read -r pair; do
		[ -n "$pair" ] || continue
		label="${pair%%:*}"
		dir="${pair#*:}"
		[ -d "$dir" ] && printf '%s\t%s\n' "$label" "$dir"
	done

	# Claude Code plugins: only the installed version of each, not the whole cache
	manifest="$HOME/.claude/plugins/installed_plugins.json"
	[ -f "$manifest" ] || return 0
	if command -v jq >/dev/null 2>&1; then
		jq -r '.plugins | to_entries[] | (.key | split("@")[0]) as $p | .value[] | "plugin:\($p)\t\(.installPath)/skills"' "$manifest" 2>/dev/null
	elif command -v python3 >/dev/null 2>&1; then
		python3 -I -c 'import json,sys
for k,v in json.load(open(sys.argv[1]))["plugins"].items():
    for e in v: print("plugin:%s\t%s/skills" % (k.split("@")[0], e["installPath"]))' "$manifest" 2>/dev/null
	fi | while IFS="$(printf '\t')" read -r label dir; do
		[ -d "$dir" ] && printf '%s\t%s\n' "$label" "$dir"
	done
}

# Print "name<TAB>source<TAB>SKILL.md path<TAB>description" for every skill found
_skill_index() {
	local label dir file name

	_skill_roots | while IFS="$(printf '\t')" read -r label dir; do
		find -L "$dir" -maxdepth 4 -name SKILL.md 2>/dev/null | sort | while IFS= read -r file; do
			# Read name/description from the YAML frontmatter, including folded (>-) descriptions
			awk -v dirname="$(basename "$(dirname "$file")")" '
				{ sub(/\r$/, "") }
				NR == 1 && $0 != "---" { exit }
				NR > 1 && $0 == "---" { exit }
				/^name:/ { sub(/^name:[ \t]*/, ""); name = $0; fold = 0; next }
				/^description:/ {
					sub(/^description:[ \t]*/, "")
					desc = ($0 ~ /^[>|][-+]?$/) ? "" : $0
					fold = 1
					next
				}
				fold && /^[ \t]/ { sub(/^[ \t]+/, ""); desc = desc (desc == "" ? "" : " ") $0; next }
				{ fold = 0 }
				END {
					gsub(/^["\047]|["\047]$/, "", name)
					gsub(/^["\047]|["\047]$/, "", desc)
					gsub(/\t/, " ", desc)
					printf "%s\t%s\n", (name == "" ? dirname : name), desc
				}' "$file" | while IFS="$(printf '\t')" read -r name desc; do
				case "$label" in
				plugin:*) name="${label#plugin:}:$name" ;;
				esac
				printf '%s\t%s\t%s\t%s\n' "$name" "$label" "$file" "$desc"
			done
		done
	done
}

# List every skill on this computer (Claude, ~/.agents, Codex, Cursor, plugins)
# Usage: listskills [keyword]   (keyword filters name, source and description)
listskills() {
	local width broken

	width="${COLUMNS:-120}"
	_skill_index | sort -f | awk -F '\t' -v width="$width" -v q="${1:-}" '
		BEGIN { printf "%-34s %-18s %s\n", "SKILL", "SOURCE", "DESCRIPTION"; q = tolower(q) }
		q != "" && index(tolower($1 " " $2 " " $4), q) == 0 { next }
		{
			room = width - 55
			if (room < 20) room = 20
			d = $4
			if (length(d) > room) d = substr(d, 1, room - 3) "..."
			printf "%-34s %-18s %s\n", $1, $2, d
			n++
		}
		END { printf "\n%d skill(s). Claude Code sees: claude, plugin:*, project.\n", n }'

	# Flag skill links in Claude's folder whose target no longer exists
	broken="$(find "$HOME/.claude/skills" -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null)"
	if [ -n "$broken" ]; then
		echo "Broken skill links (target missing):"
		printf '%s\n' "$broken" | sed 's/^/  /'
	fi
}

# Show full details for a skill by name
# Usage: skilldetails <name> [-f]   (-f: also print the whole SKILL.md)
skilldetails() {
	local query full matches

	query="$1"
	full="${2:-}"
	if [ -z "$query" ]; then
		echo "Usage: skilldetails <name> [-f]" >&2
		echo "Example: skilldetails email-follow-up" >&2
		return 1
	fi

	# Match the exact name, or the skill part of a plugin:skill name
	matches="$(_skill_index | awk -F '\t' -v q="$query" '$1 == q || $1 ~ (":" q "$")')"
	if [ -z "$matches" ]; then
		echo "No skill named '$query'. Try: listskills $query" >&2
		return 1
	fi

	printf '%s\n' "$matches" | while IFS="$(printf '\t')" read -r name label file desc; do
		echo "$name"
		printf '  Source:      %s\n' "$label"
		printf '  File:        %s\n' "$file"
		if [ -L "$(dirname "$file")" ]; then
			printf '  Links to:    %s\n' "$(readlink "$(dirname "$file")")"
		fi
		case "$label" in
		claude | plugin:* | project) printf '  Claude Code: yes\n' ;;
		agents) printf '  Claude Code: no (run syncskills to link it)\n' ;;
		*) printf '  Claude Code: no\n' ;;
		esac
		if grep -q '^disable-model-invocation: *true' "$file"; then
			printf '  Invocation:  manual only (/%s)\n' "${name##*:}"
		fi
		printf '%s\n' "$desc" | fold -s -w "$((${COLUMNS:-100} - 16))" |
			sed -e '1s/^/  Description: /' -e '2,$s/^/               /'
		if [ "$full" = "-f" ]; then
			echo
			cat "$file"
		fi
		echo
	done
}