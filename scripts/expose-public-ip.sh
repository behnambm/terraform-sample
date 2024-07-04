#!/bin/sh

# Get the public IP address
public_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

# Check if the public_ip is retrieved successfully
if [ -z "$public_ip" ]; then
  echo "Failed to retrieve the public IP address."
  exit 1
fi

echo "Publich IP: " $public_ip

# Patch the Kubernetes service with the retrieved public IP address
kubectl patch svc webapp-svc -n default -p "{\"spec\": {\"type\": \"LoadBalancer\", \"externalIPs\":[\"$public_ip\"]}}"

# Check if the kubectl command was successful
if [ $? -eq 0 ]; then
  echo "Service patched successfully with public IP: $public_ip"
else
  echo "Failed to patch the service."
  exit 1
fi
