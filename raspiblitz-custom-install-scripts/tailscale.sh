#!/bin/bash

echo "# Install Tailscale"
mv  /var/lib/tailscale /var/lib/tailscale.backup
curl -fsSL https://tailscale.com/install.sh | sh
systemctl stop tailscaled
rm -rf /var/lib/tailscale
cp -r /mnt/hdd/app-data/tailscale /var/lib
systemctl start tailscaled
echo "# Tailscale install done"
