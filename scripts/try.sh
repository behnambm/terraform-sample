#!/bin/bash

# Function to execute a command until it succeeds
execute_until_success() {
    local cmd="$1"
    until eval "$cmd"; do
        echo "Command failed. Retrying..."
        sleep 3
    done
}

# Check if a script path is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/script.sh"
    exit 1
fi

# Get the script path from the argument
script_path="$1"

# Ensure the script is executable
if [ ! -x "$script_path" ]; then
    chmod +x "$script_path"
fi

# Execute the provided script until it succeeds
execute_until_success "$script_path"

echo "Script executed successfully."
