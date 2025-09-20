apt update && apt install -y sudo
useradd -m -s /bin/bash -u 2001 ansible
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
sudo -u ansible mkdir /home/ansible/.ssh
sudo -u ansible echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGb3eQ+Ba7w8znhVZxf3XbPcvc9bAuftymq9+zhsoFMX adm_kelhamtech@kt-admin01" > /home/ansible/.ssh/authorized_keys
