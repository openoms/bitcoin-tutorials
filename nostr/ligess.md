# Set up your lightning address and Zap (NIP57) server with [ligess](https://github.com/Dolu89/ligess)

## Requirements
* an LND node accessible over Tor (a Raspiblitz env assumed here)
* a simple linux VPS with root access
* a (sub)domain with the A Record pointing to public IPaddress of the VPS
## Install ligess
*
  ```
  # install nodejs from https://github.com/nodesource/distributions
  curl -fsSL https://deb.nodesource.com/setup_19.x | sudo bash - &&\
  sudo apt-get install -y nodejs
  # yarn
  sudo npm install --global yarn
  sudo yarn config set --home enableTelemetry 0

  # create user
  sudo adduser --disabled-password --gecos "" ligess
  cd /home/ligess || exit 1

  sudo -u ligess yarn config set --home enableTelemetry 0

  # download ligess
  sudo -u ligess git clone https://github.com/dolu89/ligess
  cd ligess
  sudo -u ligess yarn install

  sudo -u ligess cp .env.example .env
  ```

## Bootstrap the zapper node
* generate a new private key at https://iris.to
* save the hex private key for ligess
* save the hex public key (for NIP-05)
* keep the window open to add the NIP-05 identifier when ready

## Edit the .env config file with your info
*
  ```
  sudo nano /home/ligess/ligess/.env
  ```
### Fill the following options
* using Tor to connect to the REST port of an LND node (Raspiblitz)
  ```
  # choose a username
  LIGESS_USERNAME=ligess
  # set your domain
  LIGESS_DOMAIN=YOUR_DOMAIN.com
  # choose a port
  PORT=3100
  # don't use Tor on the same machine as the node
  LIGESS_TOR_PROXY_URL=socks5h://127.0.0.1:9050
  LIGESS_LN_BACKEND=LND
  LIGESS_LND_REST=https://<onion link from CONNECT - MOBILE - ZEUS - CONSOLE QRcode>:8080
  LIGESS_LND_MACAROON=<hex invoice macaroon from CONNECT menu>
  LIGESS_NOSTR_ZAPPER_PRIVATE_KEY=<use a new nostr hex key from iris.to and save it>
  ```

## Run the server
* in `tmux` to keep running after the terminal is closed
  ```
  sudo -u ligess yarn dev
  ```
* alternatively set up a systemd service to return after VPS restarts


# NIP05
## create a json file called nostr.json with your and the zapper username and hex pubkeys
*
  ```
  sudo nano /var/www/html/.well-known/nostr.json
  ```
  ```
  {
    "names": {
      "username": "hex_public_key_1",
      "zapper": "hex_public_key_2"
    }
  }
  ```

# SSL config
## Set up SSL for a (sub)domain
* use ths script to set up nginx: https://github.com/openoms/bitcoin-tutorials/tree/master/nginx#add-a-custom-subdomain
* consider using [Caddy](https://github.com/caddyserver/caddy) to have a much simpler configuration

## Nginx snippets
* paste these in your nginx config file in `/etc/nginx/sites-enabled/YOURDOMAIN.conf`
* test and restart nginx:
  ```
  sudo nginx -t && sudo systemctl restart nginx
  ```

### NIP-05
*
  ```
  location /.well-known/nostr.json {
    add_header 'Access-Control-Allow-Origin' '*';
    alias /var/www/html/.well-known/nostr.json;
  }
  ```
### LNaddress and Zap server
*
  ```
  location /.well-known/lnurlp {
    add_header 'Access-Control-Allow-Origin' '*';

    proxy_pass      http://127.0.0.1:3100;
    proxy_redirect off;

    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    proxy_read_timeout 600;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    }
  }
  ```

## Finish
* add the NIP-05 identifier and lightning address to your nostr profile
* add the NIP-05 identifier to the zapper profile and broadcast it's relays publicly
