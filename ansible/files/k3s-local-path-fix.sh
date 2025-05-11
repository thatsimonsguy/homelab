#!/bin/bash

TARGET_PATH="/mnt/nas/k8sconfig"
PATCH_FILE="/usr/local/share/local-path-patch.json"

echo "Waiting for local-path-provisioner pod to be Ready..."
until kubectl -n kube-system get pods -l app=local-path-provisioner -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q True; do
  sleep 1
done

attempt=1
max_attempts=15

while (( attempt <= max_attempts )); do
  echo "Attempt $attempt: Checking if local-path-config contains expected NAS path..."

  current_config=$(kubectl -n kube-system get configmap local-path-config -o jsonpath='{.data.config\.json}' 2>/dev/null)

  if echo "$current_config" | grep -q "$TARGET_PATH"; then
    echo "✅ Config already contains correct NAS path. Exiting."
    exit 0
  fi

  echo "⏳ Config missing NAS path. Replacing local-path-config..."
  kubectl get configmap local-path-config -n kube-system -o json | \
    jq --slurpfile patch "$PATCH_FILE" \
      '.data["config.json"] = ($patch[0].data["config.json"])' | \
    kubectl replace -f -

  echo "🔁 Restarting local-path-provisioner..."
  kubectl -n kube-system delete pod -l app=local-path-provisioner --ignore-not-found

  echo "⏸ Waiting before next check..."
  sleep 5
  ((attempt++))
done

echo "❌ Failed to apply config after $max_attempts attempts."
exit 1
