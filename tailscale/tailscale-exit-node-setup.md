# TESTED ON A DEBIAN 13 VPS
```
curl -fsSL https://tailscale.com/install.sh | sh

sudo tailscale up --advertise-exit-node
# Warning: IP forwarding is disabled, subnet routing/exit nodes will not work.
# See https://tailscale.com/s/ip-forwarding
# Warning: UDP GRO forwarding is suboptimally configured on eth0, UDP forwarding throughput capability will increase with a configuration change.
# See https://tailscale.com/s/ethtool-config-udp-gro


# See https://tailscale.com/s/ip-forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
# net.ipv4.ip_forward = 1
# net.ipv6.conf.all.forwarding = 1
# net.ipv4.ip_forward = 1
# net.ipv6.conf.all.forwarding = 1


# See https://tailscale.com/s/ethtool-config-udp-gro
NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
sudo ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off

sudo mkdir -p /etc/networkd-dispatcher/routable.d/

printf '#!/bin/sh\n\nethtool -K %s rx-udp-gro-forwarding on rx-gro-list off \n' "$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")" | sudo tee /etc/networkd-dispatcher/routable.d/50-tailscale
sudo chmod 755 /etc/networkd-dispatcher/routable.d/50-tailscale

sudo /etc/networkd-dispatcher/routable.d/50-tailscale
test $? -eq 0 || echo 'An error occurred.'
```
