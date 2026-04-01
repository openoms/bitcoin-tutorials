# Raspberry Pi 5 VPN Router — via Tailscale Exit Node

Build a home VPN router from a Raspberry Pi 5, using OpenWrt and Tailscale. All LAN client traffic exits through a remote Tailscale exit node — no VPN client needed on the clients.

## Table of Contents

1. [Parts List](#parts-list)
2. [Network Topology](#network-topology)
3. [Installing OpenWrt](#1-installing-openwrt)
4. [Network Configuration](#2-network-configuration)
5. [Installing Tailscale](#3-installing-tailscale)
6. [Connecting to a Remote Exit Node](#4-connecting-to-a-remote-exit-node)
7. [Auto-Start and Optimization](#5-auto-start-and-optimization)
8. [Performance](#performance)
9. [Troubleshooting](#troubleshooting)

## Parts List

| Part | Recommendation | Notes |
|------|---------------|-------|
| **Raspberry Pi 5** (4GB or 8GB) | [Official resellers](https://www.raspberrypi.com/products/raspberry-pi-5/) | 4GB is more than enough for a router |
| **USB 3.0 Gigabit Ethernet adapter** | RTL8153 chipset adapter | See below |
| **microSD card** (16GB+) | Samsung EVO Plus, SanDisk Extreme | Class 10 / A1 minimum |
| **Power supply** | Official Pi 5 USB-C 27W (5.1V/5A) | The USB GbE adapter draws extra power, don't skimp on the PSU |
| **Cooler** | [Official Active Cooler](https://www.raspberrypi.com/products/active-cooler/) or metal case with fan | Router runs continuously, cooling is essential |
| **Ethernet cable** (x2) | Cat5e or Cat6 | WAN + LAN |

### USB Ethernet Adapter — Which One?

**Look for the RTL8153 chipset**, not AX88179. The Realtek driver has better Linux/OpenWrt support — more stable and faster on the Pi.

Specific recommendations:
- **Ugreen USB 3.0 Gigabit Ethernet Adapter** — RTL8153, widely available, cheap
- **Cable Matters USB 3.0 to Gigabit Ethernet** — RTL8153, reliable
- **TP-Link UE300** — RTL8153, though sometimes has boot-compatibility issues on Pi

> **Tip:** Plug in the adapter *before* powering on the Pi — some adapters can cause a reboot if hot-plugged.

## Network Topology

```
Internet ←→ ISP Router ←→ [eth0 WAN] RPi5 [eth1 LAN] ←→ Switch/AP ←→ Clients
                                          ↕
                                    Tailscale tunnel
                                          ↕
                                    Remote Exit Node
```

- **eth0** (built-in port) → upstream internet/WAN side. Connect this port to the ISP router, modem-router, or another network that already has internet access.
- **eth1** (USB adapter) → local network/LAN side. Connect this port to a switch, access point, or a single client device that should use the Pi as its router.
- The Pi NATs LAN traffic and routes it through the Tailscale tunnel to a remote exit node

In short: **built-in Ethernet = upstream internet**, **USB Ethernet adapter = local network**.

## 1. Installing OpenWrt

### Download the Image

1. Go to the [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/?version=24.10.1&target=bcm27xx/bcm2712&id=rpi-5)
2. Select the **24.10.1** stable release (or newer if available)
3. Download the **Factory (SQUASHFS)** image (`.img.gz`)

> **Why SquashFS and not EXT4?** SquashFS uses a read-only root + writable overlay. Advantage: you can restore factory state anytime with `firstboot` (useful if you lock yourself out with the firewall), and it means fewer SD card writes → longer lifespan. EXT4 images don't have a factory reset option.

### Write to SD Card

Linux/macOS:
```bash
# Extract and write (replace /dev/sdX with your card's actual device)
gunzip openwrt-*.img.gz
sudo dd if=openwrt-*.img of=/dev/sdX bs=4M status=progress
sync
```

Or use [Raspberry Pi Imager](https://www.raspberrypi.com/software/): "Use custom" → select the `.img` file.

### First Boot

1. Insert the microSD into the Pi
2. Plug in the USB Ethernet adapter **first**
3. For initial setup only, connect **eth0** (built-in) to your laptop or a simple switch so you can reach OpenWrt
4. Power on
5. Wait ~1 minute for boot
6. In your browser: **http://192.168.1.1** → LuCI web interface
7. First step: set a root password: **System → Administration → Router Password**

> **Temporary setup note:** During first boot, `eth0` still carries the default OpenWrt LAN at `192.168.1.1`. After the router cutover below, `eth0` becomes the WAN port and the USB adapter (`eth1`) becomes the LAN port.

> **Direct laptop-to-Pi connection note:** On some systems, a direct Ethernet connection to the Pi on first boot may not get a DHCP lease automatically. If that happens, set a temporary static IP on your computer's Ethernet interface:
>
> - IP: `192.168.1.2`
> - Netmask: `255.255.255.0`
> - Gateway: `192.168.1.1`
>
> Then browse to `http://192.168.1.1`.

### Reproducible Direct `eth0` Setup From a Linux Laptop

This is a tested direct-connection workflow for a fresh OpenWrt boot when the USB Ethernet adapter is not working yet.

1. Disconnect the USB Ethernet adapter from the Pi.
2. Connect the laptop directly to the Pi's built-in `eth0` port.
3. Power on the Pi and wait 60-90 seconds.
4. On the laptop, check the interface and routing state:

```bash
ip -brief link
ip -brief addr
ip route
nmcli device status
```

5. If the Ethernet interface does not already have `192.168.1.2/24`, set a temporary static IPv4 address with NetworkManager:

```bash
nmcli connection modify "Wired connection 1" ipv4.method manual ipv4.addresses 192.168.1.2/24 ipv4.gateway 192.168.1.1
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
```

6. Verify that the Pi answers on the default OpenWrt address:

```bash
ping -c 3 -W 2 192.168.1.1
curl -I --max-time 5 http://192.168.1.1
ip neigh show dev enp0s31f6
```

Expected results:

- `ping` returns replies from `192.168.1.1`
- `curl` returns `HTTP/1.1 200 OK`
- `ip neigh` shows a MAC address for `192.168.1.1`

7. Open LuCI in a browser:

```text
http://192.168.1.1
```

8. After setting the root password, verify SSH access:

```bash
ssh root@192.168.1.1
```

If you want to automate the SSH login for testing, use `sshpass` with your own password:

```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.1.1
```

9. Once logged into the Pi, verify the fresh-boot network state:

```bash
uname -a
uci get system.@system[0].hostname
ip link show
ip addr show
```

On a fresh OpenWrt boot, `eth0` is typically attached to `br-lan`, and `br-lan` holds `192.168.1.1/24`.

## 2. Network Configuration

### Install the USB Ethernet Driver

Before configuring `eth1`, install the driver for the USB adapter chipset.

On older OpenWrt releases, the package manager is usually `opkg`. On OpenWrt `25.12.2`, the package manager is `apk`.

For the recommended RTL8153 adapters:

```bash
opkg update
opkg install kmod-usb-net-rtl8152
reboot
```

After reboot, verify that the adapter appears as a network interface:

```bash
ip link show
lsusb
```

If you are using an AX88179-based adapter instead, install the matching ASIX driver package rather than `kmod-usb-net-rtl8152`.

### Tested AX88179 Install On OpenWrt 25.12.2

The USB adapter used during testing identified as:

```bash
dmesg | grep -i -E "usb|ax88179|asix"
```

Relevant output:

```text
Product: AX88179
Manufacturer: ASIX Elec. Corp.
```

Because the Pi was connected directly to a laptop on `eth0` and had no upstream route yet, the driver packages were downloaded on the laptop and copied to the Pi manually.

On the Pi, verify the OS release and package manager first:

```bash
cat /etc/openwrt_release
which apk
```

On the laptop, download the required packages for OpenWrt `25.12.2` / kernel `6.12.74`:

```bash
mkdir -p downloads
curl -L -o downloads/kmod-net-selftests-6.12.74-r1.apk "https://downloads.openwrt.org/releases/25.12.2/targets/bcm27xx/bcm2712/kmods/6.12.74-1-c48576c95291bf2086b1569f64c9c7f0/kmod-net-selftests-6.12.74-r1.apk"
curl -L -o downloads/kmod-phylink-6.12.74-r1.apk "https://downloads.openwrt.org/releases/25.12.2/targets/bcm27xx/bcm2712/kmods/6.12.74-1-c48576c95291bf2086b1569f64c9c7f0/kmod-phylink-6.12.74-r1.apk"
curl -L -o downloads/kmod-phy-ax88796b-6.12.74-r1.apk "https://downloads.openwrt.org/releases/25.12.2/targets/bcm27xx/bcm2712/kmods/6.12.74-1-c48576c95291bf2086b1569f64c9c7f0/kmod-phy-ax88796b-6.12.74-r1.apk"
curl -L -o downloads/kmod-usb-net-asix-6.12.74-r1.apk "https://downloads.openwrt.org/releases/25.12.2/targets/bcm27xx/bcm2712/kmods/6.12.74-1-c48576c95291bf2086b1569f64c9c7f0/kmod-usb-net-asix-6.12.74-r1.apk"
curl -L -o downloads/kmod-usb-net-asix-ax88179-6.12.74-r1.apk "https://downloads.openwrt.org/releases/25.12.2/targets/bcm27xx/bcm2712/kmods/6.12.74-1-c48576c95291bf2086b1569f64c9c7f0/kmod-usb-net-asix-ax88179-6.12.74-r1.apk"
```

Copy them to the Pi over SSH without `scp`:

```bash
dd if=downloads/kmod-net-selftests-6.12.74-r1.apk | ssh root@192.168.1.1 'dd of=/tmp/kmod-net-selftests-6.12.74-r1.apk'
dd if=downloads/kmod-phylink-6.12.74-r1.apk | ssh root@192.168.1.1 'dd of=/tmp/kmod-phylink-6.12.74-r1.apk'
dd if=downloads/kmod-phy-ax88796b-6.12.74-r1.apk | ssh root@192.168.1.1 'dd of=/tmp/kmod-phy-ax88796b-6.12.74-r1.apk'
dd if=downloads/kmod-usb-net-asix-6.12.74-r1.apk | ssh root@192.168.1.1 'dd of=/tmp/kmod-usb-net-asix-6.12.74-r1.apk'
dd if=downloads/kmod-usb-net-asix-ax88179-6.12.74-r1.apk | ssh root@192.168.1.1 'dd of=/tmp/kmod-usb-net-asix-ax88179-6.12.74-r1.apk'
```

Install them locally on the Pi:

```bash
apk add --allow-untrusted \
  /tmp/kmod-net-selftests-6.12.74-r1.apk \
  /tmp/kmod-phylink-6.12.74-r1.apk \
  /tmp/kmod-phy-ax88796b-6.12.74-r1.apk \
  /tmp/kmod-usb-net-asix-6.12.74-r1.apk \
  /tmp/kmod-usb-net-asix-ax88179-6.12.74-r1.apk
```

Verify that the adapter appears as `eth1`:

```bash
ip link show
dmesg | grep -i -E "asix|ax88179|eth1|usb"
```

Expected kernel message:

```text
ax88179_178a ... eth1: register 'ax88179_178a' ... ASIX AX88179 USB 3.0 Gigabit Ethernet
```

If you factory-reset the Pi or reflash OpenWrt, these packages do not persist and must be installed again.

### Identify Interfaces

Via SSH (`ssh root@192.168.1.1`):

```bash
# List interfaces
ip link show
# Usually: eth0 = built-in, eth1 = USB adapter
# Verify:
dmesg | grep -i eth
```

### WAN Interface (eth0 → facing ISP)

This is the **upstream internet** port. After setup is finished, plug the Pi's built-in Ethernet port into the existing internet-connected router or modem-router.

**Network → Interfaces → Add new interface:**

| Field | Value |
|-------|-------|
| Name | `wan` |
| Protocol | DHCP client |
| Device | `eth0` |
| Firewall zone | `wan` |

If upstream DHCP does not respond, configure a static WAN address instead. Tested fallback configuration:

```bash
uci set network.wan.proto='static'
uci set network.wan.ipaddr='192.168.2.250'
uci set network.wan.netmask='255.255.255.0'
uci set network.wan.gateway='192.168.2.1'
uci del network.wan.dns 2>/dev/null || true
uci add_list network.wan.dns='1.1.1.1'
uci add_list network.wan.dns='8.8.8.8'
uci commit network
/etc/init.d/network restart
```

Verify WAN connectivity:

```bash
ip addr show eth0
ip route show
ping -c 3 192.168.2.1
ping -c 3 1.1.1.1
nslookup openwrt.org 127.0.0.1
```

### Tested UCI Cutover (`eth0` -> `wan`, `eth1` -> `lan`)

The tested command sequence to move the built-in port to `wan` and the USB adapter to `lan` was:

```bash
uci batch <<'EOF'
set network.@device[0].ports='eth1'
set network.lan.device='br-lan'
set network.lan.ipaddr='192.168.3.1/24'
set network.lan.proto='static'
set network.wan=interface
set network.wan.device='eth0'
set network.wan.proto='dhcp'
set firewall.@zone[1].network='wan'
commit network
commit firewall
EOF
/etc/init.d/network restart
/etc/init.d/firewall restart
```

**Important:** As soon as this is applied, management access moves from `eth0` to the USB adapter on `eth1`. If your laptop is still plugged into `eth0`, you will immediately lose access to `192.168.3.1` until you move the cable to the USB adapter port.

### LAN Interface (eth1 → internal network)

This is the **local network** port. Plug the USB Ethernet adapter into the switch, access point, or client side network that should be routed through Tailscale.

The default `lan` interface is on the `br-lan` bridge. Modify it:

If you need to move an already-running OpenWrt router from `192.168.1.1` to a non-conflicting LAN subnet before reassigning the LAN device, use a different private subnet such as `192.168.3.1`:

```bash
uci set network.lan.ipaddr="192.168.3.1/24"
uci commit network
/etc/init.d/network reload
```

After the reload, reconnect to the router on `192.168.3.1`.

**Network → Interfaces → LAN → Edit:**

| Field | Value |
|-------|-------|
| Protocol | Static address |
| IPv4 address | `192.168.3.1` |
| Netmask | `255.255.255.0` |
| Device | `eth1` (USB adapter) |
| DHCP | Enabled (default range is fine) |
| Firewall zone | `lan` |

> **Important:** If your upstream router already uses `192.168.2.0/24`, assign a different subnet to the Pi LAN such as `192.168.3.0/24`, otherwise there will be a conflict.

### Firewall

**Network → Firewall:** The default rules are fine:
- `lan → wan`: **ACCEPT** (LAN clients can reach the internet)
- `wan → lan`: **REJECT** (nothing comes in from outside)
- Masquerading (NAT): **ON** for the `wan` zone

Save: **Save & Apply**.

### Test

A device connected to the LAN port should receive a `192.168.3.x` address via DHCP and be able to reach the internet through the upstream router.

```bash
# From the Pi:
ping -c 3 1.1.1.1
# From a LAN client:
ping -c 3 8.8.8.8
```

## 3. Installing Tailscale

### Package Installation

On OpenWrt releases that still use `opkg`:

```bash
opkg update
opkg install tailscale
```

On OpenWrt `25.12.2`, the tested installation used `apk` and required `kmod-tun`.

If the Pi does not yet have working internet access, download the packages on another machine:

```bash
curl -L -o downloads/kmod-tun-6.12.74-r1.apk "https://downloads.openwrt.org/releases/25.12.2/targets/bcm27xx/bcm2712/kmods/6.12.74-1-c48576c95291bf2086b1569f64c9c7f0/kmod-tun-6.12.74-r1.apk"
curl -L -o downloads/tailscale-1.94.1-r1.apk "https://downloads.openwrt.org/releases/25.12.2/packages/aarch64_cortex-a76/packages/tailscale-1.94.1-r1.apk"
dd if=downloads/kmod-tun-6.12.74-r1.apk | ssh root@192.168.1.1 'dd of=/tmp/kmod-tun-6.12.74-r1.apk'
dd if=downloads/tailscale-1.94.1-r1.apk | ssh root@192.168.1.1 'dd of=/tmp/tailscale-1.94.1-r1.apk'
```

Then install locally on the Pi:

```bash
apk add --allow-untrusted /tmp/kmod-tun-6.12.74-r1.apk /tmp/tailscale-1.94.1-r1.apk
```

> **Note:** The Tailscale package takes ~22 MB of space. No issue with a 16GB SD card.

### Start and Log In

```bash
# Enable and start the service
/etc/init.d/tailscale enable
/etc/init.d/tailscale start

# Log in
tailscale up --accept-routes
```

Tested interactive install/login flow on the Pi:

```bash
apk add tailscale
tailscale login
```

After login, verify the assigned Tailscale IPv4 address:

```bash
tailscale status
tailscale ip -4
ip addr show tailscale0
```

Verify the package install and daemon state:

```bash
tailscale version
/etc/init.d/tailscale status
ip link show tailscale0
```

During tested offline installation, the service started successfully, but `tailscale up` could not complete until the Pi had a working WAN route and DNS resolution.

If you factory-reset the Pi, `tailscale` and `kmod-tun` are removed and must be reinstalled.

This gives you a link — open it in your browser and log in with your Tailscale account. The Pi will appear in the admin console: [https://login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines)

### Firewall Zone for Tailscale

**Network → Firewall → Add zone:**

| Field | Value |
|-------|-------|
| Name | `tailscale` |
| Input | ACCEPT |
| Output | ACCEPT |
| Forward | ACCEPT |
| Covered devices | `tailscale0` |
| Allow forward from | `lan` |
| Allow forward to | `lan`, `wan` |

**Save & Apply.**

Tested UCI firewall setup for router access over Tailscale:

```bash
uci batch <<'EOF'
add firewall zone
set firewall.@zone[-1].name='tailscale'
set firewall.@zone[-1].device='tailscale0'
set firewall.@zone[-1].input='ACCEPT'
set firewall.@zone[-1].output='ACCEPT'
set firewall.@zone[-1].forward='ACCEPT'
add firewall forwarding
set firewall.@forwarding[-1].src='tailscale'
set firewall.@forwarding[-1].dest='lan'
add firewall forwarding
set firewall.@forwarding[-1].src='lan'
set firewall.@forwarding[-1].dest='tailscale'
commit firewall
EOF
/etc/init.d/firewall restart
```

`tailscale0` does not need to be added as a normal OpenWrt network interface. Tailscale creates and manages that device itself. In OpenWrt, the required integration point is the firewall zone for the `tailscale0` device.

If LAN clients should egress through a Tailscale exit node, enable masquerading on the `tailscale` zone as well:

```bash
uci set firewall.@zone[-1].masq='1'
uci commit firewall
/etc/init.d/firewall restart
```

After this, the router itself should be reachable over its Tailscale IP for both SSH and LuCI.

Example tested access pattern:

```bash
ssh root@<TAILSCALE_IP>
```

LuCI over Tailscale:

```text
http://<TAILSCALE_IP>
```

## 4. Connecting to a Remote Exit Node

### Prerequisite: An Exit Node in Your Tailscale Network

You need another machine in your tailnet running as an exit node. This can be:
- A VPS (e.g., Hetzner, DigitalOcean) somewhere in the world
- Another home machine in a different country
- Any device running Tailscale

On that machine:
```bash
tailscale up --advertise-exit-node
```

Then in the [Tailscale Admin Console](https://login.tailscale.com/admin/machines), approve the exit node:
**Machine → "..." menu → Edit route settings → Use as exit node ✓**

### Point the Pi to the Exit Node

```bash
# List available exit nodes
tailscale exit-node list

# Connect (replace <HOSTNAME> with the exit node's name)
tailscale set --exit-node=<HOSTNAME> --exit-node-allow-lan-access=true

# Verify public egress from the Pi
wget -qO- https://ifconfig.me/ip
```

Manual checks that the exit-node routing is active:

```bash
# Show Tailscale status and current exit-node state
tailscale status

# Show detailed exit-node status
tailscale status --json | grep -E 'ExitNode|ExitNodeOption'

# Confirm that LAN access remains enabled while using the exit node
tailscale debug prefs | grep ExitNodeAllowLANAccess

# Show the Tailscale policy-routing table
ip route show table all | grep tailscale0

# Show the router's public IP as seen from the internet
wget -qO- https://ifconfig.me/ip
```

What to look for:

- `tailscale status` should show the chosen exit node as active
- `tailscale debug prefs` should show `ExitNodeAllowLANAccess: true`
- `ip route show table all` should include `default dev tailscale0 table 52`
- the public IP returned by `ifconfig.me` should match the exit node's egress IP, not the upstream ISP IP

### Why Does This Work for LAN Clients Too?

LAN clients are NATed through the Pi. When the Pi's traffic goes through the exit node, **all LAN client traffic automatically goes there too** — no need to install Tailscale on the clients.

### Disable Exit Node

```bash
# Revert to normal routing (exit via ISP)
tailscale set --exit-node=
```

## 5. Auto-Start and Optimization

### CPU Performance Governor

A router is under constant load; the powersave governor slows down crypto operations:

```bash
# Set immediately
echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor

# Set at boot — add to /etc/rc.local (before exit 0):
echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
```

### Tailscale Exit Node Setting After Reboot

`tailscale set --exit-node=<HOSTNAME>` **persists across reboots** — Tailscale stores the setting in its state file (`/var/lib/tailscale/`), and the daemon applies it automatically on restart. No extra boot script needed.

### Watchdog

If the active exit node stops working, a watchdog script can switch to a fallback exit node.

Create `/etc/tailscale-watchdog.sh`:

```bash
cat << 'EOF' > /etc/tailscale-watchdog.sh
#!/bin/sh
PRIMARY_EXIT_NODE="<PRIMARY_HOSTNAME>"
FALLBACK_EXIT_NODE="<FALLBACK_HOSTNAME>"
TEST_URL="https://ifconfig.me/ip"

set_exit_node() {
    tailscale set --exit-node="$1" --exit-node-allow-lan-access=true
}

if wget -qO- "$TEST_URL" >/dev/null 2>&1; then
    exit 0
fi

logger -t tailscale-watchdog "Primary path failed, switching to fallback exit node"
set_exit_node "$FALLBACK_EXIT_NODE"
sleep 10

if wget -qO- "$TEST_URL" >/dev/null 2>&1; then
    exit 0
fi

logger -t tailscale-watchdog "Fallback exit node failed, retrying primary exit node"
set_exit_node "$PRIMARY_EXIT_NODE"
EOF
chmod +x /etc/tailscale-watchdog.sh
```

Test it manually:

```bash
/etc/tailscale-watchdog.sh
logread | grep tailscale-watchdog
tailscale status
tailscale debug prefs | grep ExitNodeAllowLANAccess
```

Add it to cron (every 5 minutes):

```bash
echo '*/5 * * * * /etc/tailscale-watchdog.sh' >> /etc/crontabs/root
/etc/init.d/cron restart
```

Notes:

- The script checks whether the router can still reach the internet before switching exit nodes.
- `--exit-node-allow-lan-access=true` is required so LAN clients keep working after the failover.
- Replace `<PRIMARY_HOSTNAME>` and `<FALLBACK_HOSTNAME>` with the hostnames shown by `tailscale exit-node list`.

## Performance

| Measurement | Expected Value |
|-------------|---------------|
| WireGuard (Tailscale) throughput | ~800–900 Mbps |
| One-direction max (CPU-limited) | ~1 Gbps |
| Latency overhead | +1–3 ms (within LAN) |

The Pi 5's Cortex-A76 cores have ARMv8 crypto extensions, which provide hardware acceleration for WireGuard. On a 1 Gbps connection, the CPU is the bottleneck, not the NIC.

## Troubleshooting

### USB Adapter Not Showing Up

```bash
dmesg | grep -i eth
lsusb
ip link show
```

If the adapter uses the recommended RTL8153 chipset, install the driver and reboot:

```bash
opkg update
opkg install kmod-usb-net-rtl8152
reboot
```

If `eth1` is still not visible, try plugging in the adapter with the Pi powered off, then boot.

### Tailscale Won't Connect

```bash
tailscale status
# If "Logged out":
tailscale up --accept-routes
```

### LAN Clients Not Getting IP Addresses

```bash
# Is the DHCP server running?
/etc/init.d/dnsmasq status
# Check logs:
logread | grep dhcp
```

### No Internet via Exit Node

```bash
# Exit node status
tailscale exit-node list
# Verify that the selected exit node is actually enabled for default routing
tailscale debug prefs | grep -E 'RouteAll|ExitNodeID|ExitNodeIP|ExitNodeAllowLANAccess'
# Ping test directly from the Pi
ping -c 3 1.1.1.1
# If it fails, temporarily disable:
tailscale set --exit-node=
# If it works without exit node, the issue is with the exit node
```

If the router should share the exit-node IP with all LAN clients, these conditions must all be true:

- `tailscale set --exit-node=<HOSTNAME> --exit-node-allow-lan-access=true --accept-routes=true` has been applied
- `tailscale debug prefs` shows `RouteAll: true`
- the OpenWrt firewall has a `tailscale` zone with `masq='1'`
- there is a `lan -> tailscale` forwarding rule

Recovery commands:

```bash
# Re-enable the exit node for full internet routing
tailscale set --exit-node=<HOSTNAME> --exit-node-allow-lan-access=true --accept-routes=true

# Verify the policy-routing table points default traffic at tailscale0
ip route show table 52

# Verify LAN client traffic is being NATed to the router's Tailscale IP
grep 'src=192.168.3.' /proc/net/nf_conntrack
```

Important: `ExitNodeID` can still be populated while the exit node is effectively disabled. The setting that decides whether clients actually use the exit node is `RouteAll`. If `RouteAll: false`, LAN clients fall back to the normal WAN path.

## References

- [OpenWrt Firmware Selector — RPi 5](https://firmware-selector.openwrt.org/?version=24.10.1&target=bcm27xx/bcm2712&id=rpi-5)
- [Tailscale Exit Nodes documentation](https://tailscale.com/kb/1103/exit-nodes)
- [Tailscale Subnet Routers documentation](https://tailscale.com/kb/1019/subnets)
- [Tailscale on OpenWrt — WunderTech](https://www.wundertech.net/how-to-set-up-tailscale-on-openwrt/)
- [OpenWrt Forum — Tailscale exit node on 24.10](https://forum.openwrt.org/t/how-to-configure-tailscale-18-02-on-24-10-to-access-remote-exit-node/226561)
