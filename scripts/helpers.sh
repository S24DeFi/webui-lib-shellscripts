#!/bin/sh
# HELPER FUNCTIONS
# Shared utility functions used across multiple script modules
# These functions provide common functionality for file operations, navigation, and development tools

# Open a file, URL, or folder in the default application
# Usage: trigger <path_or_url>
trigger() {
    if [ -z "$1" ]; then
        echo "Usage: trigger <path_or_url>" >&2
        return 1
    fi
    open "$1"
}

# Search for aliases containing a keyword
# Usage: showme <keyword>
showme() {
    if [ -z "$1" ]; then
        echo "Usage: showme <keyword>" >&2
        echo "Example: showme git" >&2
        return 1
    fi
    alias | grep "$1"
}

# Find files containing a search string
# Usage: locate <search_string>
locate() {
    if [ -z "$1" ]; then
        echo "Usage: locate <search_string>" >&2
        return 1
    fi
    grep -Ril "$1" ./
}

# Change permissions on a folder or file (use with caution)
# Usage: iwant <path>
iwant() {
    if [ -z "$1" ]; then
        echo "Usage: iwant <path>" >&2
        return 1
    fi
    if [ ! -e "$1" ]; then
        echo "Error: Path does not exist: $1" >&2
        return 1
    fi
    sudo chmod -R 777 "$1"
}

# Remove CR LF line endings from a file (Windows to Unix conversion)
# Usage: macify <filename>
macify() {
    if [ -z "$1" ]; then
        echo "Usage: macify <filename>" >&2
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: File does not exist: $1" >&2
        return 1
    fi
    sed -i -e 's/\r$//' "$1"
}

# Create a new folder in notes directory and navigate to it
# Usage: newfolder <folder_name>
newfolder() {
    if [ -z "$1" ]; then
        echo "Usage: newfolder <folder_name>" >&2
        return 1
    fi
    if ! command -v notes >/dev/null 2>&1; then
        echo "Error: 'notes' command not found. Please ensure notes alias is defined." >&2
        return 1
    fi
    notes && mkdir -p "$1" && cd "$1" && printf "New folder system created: %s\n" "$1" && printf "start here > "
}

# Watch and compile SASS files
# Usage: watchit <input_file> <output_file>
watchit() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: watchit <input_file> <output_file>" >&2
        return 1
    fi
    if ! command -v sass >/dev/null 2>&1; then
        echo "Error: sass command not found. Please install sass." >&2
        return 1
    fi
    sass --watch "$1:$2"
}

# Update terminal tab name (macOS)
# Usage: tabname <name>
tabname() {
    if [ -z "$1" ]; then
        echo "Usage: tabname <name>" >&2
        return 1
    fi
    printf '\033]1;%s\007' "$1"
}

# Set upstream branch for current branch
# Usage: setupstream <branch_name>
setupstream() {
    if [ -z "$1" ]; then
        echo "Usage: setupstream <branch_name>" >&2
        return 1
    fi
    git branch --set-upstream-to="origin/$1" "$1"
}

# Run yarn test in watch mode for a specific file
# Usage: yw <file_path>
yw() {
    if [ -z "$1" ]; then
        echo "Usage: yw <file_path>" >&2
        return 1
    fi
    yarn test --watch "$1"
}
alias pkg="less package.json" #show the content of the package json file
alias esc="vi .shell-config" #edit the shell config file
alias egi="vi .gitignore" #edit the git ignore file
