#!/bin/bash

while ! sudo sh /tmp/install-docker.sh; do
    echo "Install failed, retrying..."
    sleep 2
done

echo "Install succeeded!"

