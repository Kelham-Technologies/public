#!/bin/bash
set -e

# -- Configuration --
ANSIBLE_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGb3eQ+Ba7w8znhVZxf3XbPcvc9bAuftymq9+zhsoFMX adm_kelhamtech@kt-admin01"
TSKEY_URL="https://kelhamtechnologies.cloud/bootstrap/tskey"
TS_TAGS="tag:infra"

# -- Sanity check --
if [ -z "$BPASS" ]; then
  echo "ERROR: BPASS environment variable not set"
  echo "Usage: BPASS=yourpassword curl -L https://kelhamtechnologies.cloud/deb-init | sudo BPASS=\$BPASS bash"
  exit 1
fi

# -- Base setup --
apt update && apt install -y sudo curl

# -- Ansible user --
useradd -m -s /bin/bash -u 2001 ansible 2>/dev/null || echo "User ansible already exists, skipping"
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

sudo -u ansible mkdir -p /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
echo "$ANSIBLE_PUBKEY" > /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh

# -- Fetch Tailscale auth key --
echo "Fetching Tailscale auth key..."
TSKEY=$(curl -sf "https://bootstrap:${BPASS}@${TSKEY_URL#https://}")

if [ -z "$TSKEY" ]; then
  echo "ERROR: Failed to fetch Tailscale key — check BPASS or server config"
  exit 1
fi

# -- Install and join Tailscale --
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "Joining Tailscale network..."
tailscale up --authkey "$TSKEY" --advertise-tags="$TS_TAGS"

echo "Done. Tailscale status:"
tailscale status

