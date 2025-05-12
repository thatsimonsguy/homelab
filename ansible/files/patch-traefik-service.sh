#!/bin/bash
set -e
echo "[+] Patching Traefik service to assign static IP..."
kubectl patch svc traefik -n kube-system \
  -p '{"spec": {"type": "LoadBalancer", "loadBalancerIP": "192.168.2.244"}}'
