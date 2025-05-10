#!/bin/bash

echo "Waiting for K3s API to be available..."
until kubectl get nodes &>/dev/null; do sleep 1; done

echo "Patching local-path-config..."
kubectl -n kube-system patch configmap local-path-config \
  --type merge \
  --patch "$(cat <<'EOF'
{
  "data": {
    "config.json": "{ \"nodePathMap\": [ { \"node\": \"DEFAULT_PATH_FOR_NON_LISTED_NODES\", \"paths\": [\"/var/lib/rancher/k3s/storage\"] }, { \"node\": \"burdturglar\", \"paths\": [\"/mnt/nas/k8sconfig\"] } ] }"
  }
}
EOF
)"

echo "Restarting local-path-provisioner..."
kubectl -n kube-system delete pod -l app=local-path-provisioner