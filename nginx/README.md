<!-- omit from toc -->
# Nginx scripts

- [Lightning Payable VPS services](#lightning-payable-vps-services)
- [Add a custom subdomain](#add-a-custom-subdomain)
- [Snippets for NIP5, LNaddress and LNURLpay](#snippets-for-nip5-lnaddress-and-lnurlpay)
- [CORS headers for ln-address](#cors-headers-for-ln-address)
- [Add a subdomain for a Mempool instance](#add-a-subdomain-for-a-mempool-instance)
- [Add subdomain for an Electrum Server](#add-subdomain-for-an-electrum-server)
- [Set up SSL access for the Ride The Lightning web UI on the RaspiBlitz](#set-up-ssl-access-for-the-ride-the-lightning-web-ui-on-the-raspiblitz)
- [Resources](#resources)


## Lightning Payable VPS services
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

## Snippets for NIP5, LNaddress and LNURLpay
* [snippets](/nginx/nostr_lnaddress_snippets.conf)

## CORS headers for ln-address

* allow the `GET` `request_method` with these lines in `location / { }`
```
location / {

    if ($request_method != 'GET') {
        return 403;
    }
    add_header 'Access-Control-Allow-Origin' '*';

}
```

* More info from https://enable-cors.org/server_nginx.html

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

## Resources

* Virtual Hosts on nginx <https://gist.github.com/soheilhy/8b94347ff8336d971ad0>
