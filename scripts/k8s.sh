#!/bin/bash

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
if [ $? -ne 0 ]; then
  echo "adding k8s key failed"
  exit 2
fi


echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
if [ $? -ne 0 ]; then
  echo "adding k8s to source list failed."
  exit 2
fi


echo "k8s repo added successfully."
