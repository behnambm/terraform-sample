#!/bin/bash

# URL and file path
URL="https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.14/cri-dockerd_0.3.14.3-0.ubuntu-focal_amd64.deb"
FILE="/tmp/cri-dockerd_0.3.14.3-0.ubuntu-focal_amd64.deb"

# Function to check if the file is a valid .deb file
is_valid_deb() {
    dpkg-deb -I "$1" > /dev/null 2>&1
}

# Download and check loop
attempt=0
max_attempts=50

while [ $attempt -lt $max_attempts ]; do
    echo "Attempt $(($attempt + 1)) of $max_attempts..."

    # Download the file
    curl -fsSL "$URL" -o "$FILE"

    # Check if the file is a valid .deb file
    if is_valid_deb "$FILE"; then
        echo "Download successful and file is valid."
        break
    else
        echo "Download failed or file is invalid."
        attempt=$(($attempt + 1))
        rm -f "$FILE"
    fi

    if [ $attempt -eq $max_attempts ]; then
        echo "Max attempts reached. Exiting."
        exit 1
    fi
done

# Install the .deb file
sudo apt install -y "$FILE"

# Clean up
rm -f "$FILE"

echo "Installation completed."
