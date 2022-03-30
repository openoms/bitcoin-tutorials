# Nginx scripts

Lightning Payable VPS services:
* [host4coins.net](https://host4coins.net) - from $8/month - only email address is required
* A long list of providers: <https://bitcoin-vps.com/#VPS-Europe>

## Add a custom subdomain

In this example configuration a redirect is added to a custom service on the LAN (or VPN).  
<https://github.com/openoms/bitcoin-tutorials/blob/master/nginx/custom_website_subdomain.sh>  
To download, check and run:
```
wget -O custom_website_subdomain.sh https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/nginx/custom_website_subdomain.sh

cat custom_website_subdomain.sh

bash custom_website_subdomain.sh
```

## Add a subdomain for a Mempool instance

In this example configuration a redirect is added to a Mempool instance on the LAN (or VPN).  
<https://github.com/openoms/bitcoin-tutorials/blob/master/nginx/mempool_subdomain.sh>  
To download, check and run:
```
wget -O mempool_subdomain.sh https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/nginx/mempool_subdomain.sh

cat mempool_subdomain.sh

bash mempool_subdomain.sh
```

## Add subdomain for an Electrum Server

In this example configuration a redirect and SSL encryption added to a Fulcrum instance.  
<https://github.com/openoms/bitcoin-tutorials/blob/master/nginx/electrum_server_subdomain.sh>  
To download, check and run:
```
wget -O electrum_server_subdomain.sh
https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/nginx/electrum_server_subdomain.sh

cat electrum_server_subdomain.sh

bash electrum_server_subdomain.sh
```

## Set up SSL access for the Ride The Lightning web UI on the RaspiBlitz

Have a look through the script here: [bonus.SSL_for_RTL.sh](bonus.SSL_for_RTL.sh).

To download, check and run:
```
wget -O bonus.SSL_for_RTL.sh https://github.com/openoms/bitcoin-tutorials/raw/master/nginx/bonus.SSL_for_RTL.sh

cat bonus.SSL_for_RTL.sh

bash bonus.SSL_for_RTL.sh
```

