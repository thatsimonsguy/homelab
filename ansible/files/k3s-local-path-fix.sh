#!/bin/bash

echo "Waiting for K3s API to be available..."
until kubectl get nodes &>/dev/null; do sleep 1; done

echo "Replacing local-path-config configmap..."
kubectl get configmap local-path-config -n kube-system -o json | \
  jq --slurpfile patch /usr/local/share/local-path-patch.json \
     '.data["config.json"] = ($patch[0].data["config.json"])' | \
  kubectl replace -f -

echo "Restarting local-path-provisioner..."
kubectl -n kube-system delete pod -l app=local-path-provisioner
