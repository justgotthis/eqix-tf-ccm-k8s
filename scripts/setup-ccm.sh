#!/bin/bash

echo "[------ Begin CCM Install -----]"

kubectl apply -f /tmp/secret.yaml
kubectl apply -f /tmp/deployment.yaml

echo "[------ End CCM Install -----]"
