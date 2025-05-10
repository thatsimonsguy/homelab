# homelab/ansible/files/k3s-local-path-fix.sh

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

---

- name: Ensure patch script exists and is executable
  hosts: k3s
  become: yes
  tasks:
    - name: Copy local-path-config patch script from template
      copy:
        src: files/k3s-local-path-fix.sh
        dest: /usr/local/bin/k3s-local-path-fix.sh
        mode: '0755'
        owner: root
        group: root

    - name: Install systemd unit for patch script
      copy:
        dest: /etc/systemd/system/k3s-local-path-fix.service
        mode: '0644'
        owner: root
        group: root
        content: |
          [Unit]
          Description=Patch local-path-config to support NAS PVCs
          After=network-online.target k3s.service
          Wants=network-online.target

          [Service]
          Type=oneshot
          ExecStart=/usr/local/bin/k3s-local-path-fix.sh
          RemainAfterExit=yes

          [Install]
          WantedBy=multi-user.target

    - name: Enable and start patch service
      systemd:
        name: k3s-local-path-fix.service
        enabled: yes
        state: started
