#!/bin/bash

# once tailscale is installed and logged in use this to copy the config to the data disk:
# sudo cp -R /var/lib/tailscale /mnt/hdd/app-data/

# these commands can be put in the custom-installs.sh
echo "# Install Tailscale"
mv  /var/lib/tailscale /var/lib/tailscale.backup
curl -fsSL https://tailscale.com/install.sh | sh
systemctl stop tailscaled
rm -rf /var/lib/tailscale
cp -r /mnt/hdd/app-data/tailscale /var/lib
systemctl start tailscaled
echo "# Tailscale install done"
