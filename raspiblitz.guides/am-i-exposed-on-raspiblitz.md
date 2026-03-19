# Install am-i-exposed on RaspiBlitz and use your local mempool API

This guide shows a manual, terminal-first setup of `am-i-exposed` on a RaspiBlitz and how to make it use your own local mempool instance instead of public `mempool.space`.

## What you will do

1. Verify mempool is running on RaspiBlitz.
2. Ensure Node.js and npm are available.
3. Install `am-i-exposed` CLI.
4. Detect the correct local mempool API base URL.
5. Run scans against your local mempool API.
6. (Optional) Use SSH tunneling from your laptop/desktop.
7. (Optional) Run the am-i-exposed Web UI on your LAN.

## Prerequisites

- RaspiBlitz is fully synced and reachable over SSH.
- You can log in as `admin`.
- Mempool app is enabled on RaspiBlitz.

SSH to your node:

```bash
ssh admin@<raspiblitz-ip-or-hostname>
```

## Step 1: Verify Mempool service on RaspiBlitz

Check RaspiBlitz mempool status:

```bash
/home/admin/config.scripts/bonus.mempool.sh status
```

Check systemd status:

```bash
sudo systemctl status mempool --no-pager
```

Expected: service should be `active (running)`.

If mempool is not enabled, turn it on from the RaspiBlitz menu, or run:

```bash
/home/admin/config.scripts/bonus.mempool.sh on
```

## Step 2: Ensure Node.js and npm are installed

`am-i-exposed` CLI requires Node.js >= 20.

Check versions:

```bash
node -v
npm -v
```

If Node.js is missing or too old, use the RaspiBlitz helper:

```bash
/home/admin/config.scripts/bonus.nodejs.sh on
```

Then open a new shell and verify again:

```bash
node -v
npm -v
```

## Step 3: Install am-i-exposed CLI

Install globally:

```bash
npm install -g am-i-exposed
```

Confirm install:

```bash
am-i-exposed --help
```

Alternative without global install:

```bash
npx am-i-exposed --help
```

## Step 4: Find the correct local mempool API base URL

RaspiBlitz setups can differ, so test candidates and keep the one that returns a block height.

### Candidate A (direct mempool backend)

```bash
curl -sS http://127.0.0.1:8999/api/v1/blocks/tip/height
```

### Candidate B (nginx proxy)

```bash
curl -k -sS https://127.0.0.1:4081/api/blocks/tip/height
```

### Candidate C (nginx http)

```bash
curl -sS http://127.0.0.1:4080/api/blocks/tip/height
```

Use whichever candidate returns a numeric height.

Common base URLs to use with `--api`:

- `http://127.0.0.1:8999/api/v1`
- `https://127.0.0.1:4081/api`
- `http://127.0.0.1:4080/api`

## Step 5: Run am-i-exposed against your local mempool

Replace `<API_BASE>` with the working base URL from Step 4.

Scan a transaction:

```bash
am-i-exposed scan tx <txid> --api <API_BASE> --json
```

Scan an address:

```bash
am-i-exposed scan address <bitcoin-address> --api <API_BASE> --json
```

Wallet audit (xpub/zpub):

```bash
am-i-exposed scan xpub <xpub-or-zpub> --api <API_BASE> --gap-limit 30 --json
```

Boltzmann analysis:

```bash
am-i-exposed boltzmann <txid> --api <API_BASE> --json
```

## Step 6 (Optional): Use your RaspiBlitz local mempool from your laptop

If you want to run `am-i-exposed` on another machine but still use RaspiBlitz mempool, create an SSH tunnel.

On your laptop:

```bash
ssh -N -L 8999:127.0.0.1:8999 admin@<raspiblitz-ip-or-hostname>
```

Keep that terminal open. In another local terminal:

```bash
am-i-exposed scan tx <txid> --api http://127.0.0.1:8999/api/v1 --json
```

If your RaspiBlitz mempool setup uses a different internal endpoint, tunnel that port and path instead.

## Step 7 (Optional): Run the am-i-exposed Web UI on your LAN

This section hosts the am-i-exposed web interface directly on RaspiBlitz and makes it reachable from other devices on your local network.

### 7.1 Build the Web UI

```bash
cd /home/admin
git clone https://github.com/Copexit/am-i-exposed.git
cd am-i-exposed
corepack enable
corepack prepare pnpm@latest --activate
pnpm install
pnpm build
```

The static site is generated into `out/`.

### 7.2 Publish static files

```bash
sudo mkdir -p /var/www/am-i-exposed
sudo rsync -a --delete /home/admin/am-i-exposed/out/ /var/www/am-i-exposed/
```

### 7.3 Add nginx site with local mempool API proxy

Create `/etc/nginx/sites-available/am-i-exposed.conf`:

```bash
sudo tee /etc/nginx/sites-available/am-i-exposed.conf >/dev/null <<'EOF'
server {
  listen 3090;
  server_name _;

  root /var/www/am-i-exposed;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }

  # Mainnet API proxy to RaspiBlitz mempool backend
  location /api/ {
    proxy_pass http://127.0.0.1:8999/api/v1/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }

  # Optional network-prefixed routes
  location /signet/api/ {
    rewrite ^/signet/api/(.*)$ /api/v1/$1 break;
    proxy_pass http://127.0.0.1:8999;
  }

  location /testnet4/api/ {
    rewrite ^/testnet4/api/(.*)$ /api/v1/$1 break;
    proxy_pass http://127.0.0.1:8999;
  }
}
EOF
```

If your working API base from Step 4 is not `http://127.0.0.1:8999/api/v1`, update the `proxy_pass` targets accordingly.

### 7.4 Enable site and reload nginx

```bash
sudo ln -sf /etc/nginx/sites-available/am-i-exposed.conf /etc/nginx/sites-enabled/am-i-exposed.conf
sudo nginx -t
sudo systemctl reload nginx
```

### 7.5 Open the LAN firewall port

```bash
sudo ufw allow 3090/tcp comment 'am-i-exposed webui'
```

### 7.6 Open from LAN

From any LAN device, open:

```text
http://<raspiblitz-ip-or-hostname>:3090
```

### 7.7 Verify Web UI + API locally

```bash
curl -I http://127.0.0.1:3090
curl -sS http://127.0.0.1:3090/api/blocks/tip/height
sudo journalctl -u nginx -n 100 --no-pager
```

## Troubleshooting

### `am-i-exposed: command not found`

- Re-open shell session.
- Check npm global bin path:

```bash
npm config get prefix
```

- Try `npx am-i-exposed ...` instead.

### API returns 404 or empty response

Your base URL is likely wrong for this mempool setup. Re-test Step 4 and switch between `/api` and `/api/v1` bases.

### HTTPS certificate error

RaspiBlitz often uses self-signed certs for local HTTPS. Use the local HTTP endpoint or the direct backend endpoint over SSH tunnel.

### Slow responses/timeouts

- First query can be slower.
- Verify mempool backend health:

```bash
sudo journalctl -u mempool -n 100 --no-pager
```

## Security notes

- Do not expose mempool backend ports directly to the internet.
- Prefer localhost access on the node or SSH tunneling.
- Keep RaspiBlitz and mempool updated.

## Quick copy-paste test

If your node uses the common RaspiBlitz backend endpoint:

```bash
npm install -g am-i-exposed
am-i-exposed scan tx 323df21f0b0756f98336437aa3d2fb87e02b59f1946b714a7b09df04d429dec2 \
  --api http://127.0.0.1:8999/api/v1 \
  --json
```
