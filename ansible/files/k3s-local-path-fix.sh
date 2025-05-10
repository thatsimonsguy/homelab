#!/bin/bash

echo "Waiting for K3s API to be available..."
until kubectl get nodes &>/dev/null; do sleep 1; done

echo "Patching local-path-config..."
kubectl -n kube-system patch configmap local-path-config \
  --type merge \
  --patch-file /usr/local/share/local-path-patch.json

echo "Restarting local-path-provisioner..."
kubectl -n kube-system delete pod -l app=local-path-provisioner
