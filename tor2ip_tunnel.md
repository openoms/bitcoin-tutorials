# Tor-to-IP tunnel service

Use the public IP address of a Virtual Private Server (VPS) to make Tor Hidden Services reachable on the clearnet.

## Advantages: 
* hides the IP of the host from the public and from the VPS
* no port forwarding needed on the LAN of the host
* additional encryption by Tor between the host and the VPS 

## Requirements:
* SSH access to a Virtual Private Server (VPS) - eg. a minimal package on Lunanode for ~3.5$/month
    * Example Lightning Payable VPS services:
        * [host4coins.net](https://host4coins.net)
        * [bitclouds.sh](https://bitclouds.sh/) or [lntxbot](https://t.me/lntxbot) `/bitclouds` 
* Note that only the root user can forward to ports below 1000.  
* Tor should not be the only encryption layer of the service as the traffic exposed on the VPS is meant to be for the `localhost`
* Always check the terms and rules of the VPS provider to avoid bans and don't do anything causing them trouble to keep these services going.

## On the VPS

* Login with ssh to the `root` user  
    `ssh root@VPS_IP_ADDRESS`
* Install `tor` (leave on default settings) and `socat`  
`# apt install tor socat`

### Set up a systemd service

* make a separate process for every connected Hidden Service to avoid restarting every connection when a service added or removed.  
Suggestion for naming the service is to put the VPS_PORT used on the VPS into the name: `tor2ip<VPS_PORT>`

* create the service file:   
`# nano /etc/systemd/system/tor2ip9236.service`
    * Paste the following and fill in:
        * the VPS_PORT you want to use (facing the public) - in this example: 9326.
        * the TOR_HIDDEN_SERVICE_ADDRESS.onion
            * get the address with:
                * `lncli getinfo` for LND port 9735
                * `sudo cat /mnt/hdd/tor/SERVICE_NAME/hostname`
        * The TOR_PORT the Hidden Service is using - in this example: 9735

    ```
    [Unit]
    Description=Tor2IP Tunnel Service
    After=network.target

    [Service]
    User=root
    Group=root
    ExecStart=/usr/bin/socat TCP4-LISTEN:9236,bind=0.0.0.0,fork SOCKS4A:localhost:TOR_HIDDEN_SERVICE_ADDRESS.onion:9735,socksport=9050
    StandardOutput=journal

    [Install]
    WantedBy=multi-user.target
    ```
* Enable and start the service:  
`# systemctl enable tor2ip9236`  
`# systemctl start tor2ip9236`

Setting up this Tor-to-IP tunnel service is now complete. You can carry on adding other services using different ports on the VPS.  
You should be able access the ports/services of the host computer through: VPS_IP_ADDRESS:VPS_PORT.
To connect to LND in the example:  
 `lncli connect NODE_PUBLIC_KEY@VPS_IP_ADDRESS:9236`
  
## Monitoring on the VPS

* To check if tunnel is active on the VPS:  
`# netstat -tulpn`

    * Look for the lines:
    ```
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    

    tcp        0      0 0.0.0.0:9236            0.0.0.0:*               LISTEN      13684/socat  
    ```

* Monitor the service with:  
`# systemctl status tor2ip9236`
```
● tor2ip9236.service - Tor2IP Tunnel Service
   Loaded: loaded (/etc/systemd/system/tor2ip9236.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2020-04-05 14:58:43 BST; 2min 23s ago
 Main PID: 13684 (socat)
    Tasks: 1 (limit: 1078)
   Memory: 540.0K
   CGroup: /system.slice/tor2ip9236.service
           └─13684 /usr/bin/socat TCP4-LISTEN:9236,bind=0.0.0.0,fork SOCKS4A:localhost:TOR_HIDDEN_SERVICE_ADDRESS.onion:9735,socksport=9050

Apr 05 14:58:43 VPS_hostname systemd[1]: Started Tor2IP Tunnel Service.
```

## Resources

* `socat` manpage:  <https://linux.die.net/man/1/socat>
* Thanks to [@emzy](https://twitter.com/emzy) for the original `socat` syntax.  
* Produced at the [#LightningHackSprint](https://wiki.fulmo.org/index.php?title=Lightning_HackSprint).  
