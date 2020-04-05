# Tor-to-IP tunnel service

## Advantages: 
* hides the IP of the host from the public and from the VPS
* no port forwarding needed on the LAN of the host
* encrypted connection over Tor

## Requirements:

* ssh access to the host computer (where the ports will be forwarded from)
* a Virtual Private Server (VPS) - eg. a minimal package on Lunanode for ~3.5$/month
    * Example Lightning Payable VPS services:
        * <https://host4coins.net>
        * <https://bitclouds.sh/> or <https://t.me/lntxbot> `/bitclouds` 
* Tor and socat running on the VPS

## On the host computer 
* login as root or run:  
`$ sudo su -`

* Check for an ssh public key:  
`# cat ./.ssh/*.pub`

* if there is none generate one (keep pressing ENTER):  
`# ssh-keygen -t rsa -b 4096`
    * keep pressing [ENTER] to use the default values:
    ```
    Generating public/private rsa key pair.
    Enter file in which to save the key (/root/.ssh/id_rsa): 
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in /root/.ssh/id_rsa.
    Your public key has been saved in /root/.ssh/id_rsa.pub.
    The key fingerprint is:
    SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx root@hostname
    The key's randomart image is:
    +---[RSA 4096]----+
    |            xxxx |
    |           xxxxx |
    |           xxxxx |
    |          xxxxxx |
    |       xxxxxxxxx |
    |      xxxxxxxx   |
    |     xxxxxxxxxx  |
    |     xxxxxxxxxxx |
    |      xxxxxxxxxx |
    +----[SHA256]-----+
    ```

* copy the ssh public key over to the VPS (fill in the VPS_IP_ADDRESS).  
Will be prompted for the root password of the VPS.  
`# ssh-copy-id root@VPS_IP_ADDRESS` 

## On the VPS

* Install tor (leave on default settings) and socat  
`# apt install tor socat`

### Set up a systemd service

Recommended to make a separate process for every connected Hidden Service to avoid restarting every connection when a service added or removed.
Suggestion for naming the service to use the port used in the name: `tor2ip<PORT>`

* create the service file:   
`# nano /etc/systemd/system/tor2ip9236.service`
    * Paste the following and fill in:
        * the PORT you want to use on the VPS (facing the public) - in this example it is 9326.
    
        * the Tor Hidden Service Address (----YOUR-ONION-ADDRESS---.onion) 
            * get the address with:
                * `lncli getinfo` for LND port 9735
                * sudo cat /mnt/hdd/tor/SERVICE_NAME/hostname
        * The PORT the Hidden Service is using - in this example it is 9735

    ```
    [Unit]
    Description=Tor2IP Tunnel Service
    After=network.target

    [Service]
    User=root
    Group=root
    ExecStart=/usr/bin/socat TCP4-LISTEN:9236,bind=0.0.0.0,fork SOCKS4A:localhost:----YOUR-ONION-ADDRESS---.onion:9735,socksport=9050
    StandardOutput=journal

    [Install]
    WantedBy=multi-user.target
    ```
* Enable and start the service:  
`# systemctl enable tor2ip9236`  
`# systemctl start tor2ip9236`

Setting up this Tor-to-IP tunnel service is now complete. You can carry on adding other services using different ports on the VPS.  
You should be able access the ports/services of the host computer through the IP:PORT of the VPS.  
For example for LND in the example:  
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
`# systemctl status tor2ip9236
```
● tor2ip9236.service - Tor2IP Tunnel Service
   Loaded: loaded (/etc/systemd/system/tor2ip9236.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2020-04-05 14:58:43 BST; 2min 23s ago
 Main PID: 13684 (socat)
    Tasks: 1 (limit: 1078)
   Memory: 540.0K
   CGroup: /system.slice/tor2ip9236.service
           └─13684 /usr/bin/socat TCP4-LISTEN:9236,bind=0.0.0.0,fork SOCKS4A:localhost:----YOUR-ONION-ADDRESS---onion:9735,socksport=9050

Apr 05 14:58:43 VPS_hostname systemd[1]: Started Tor2IP Tunnel Service.
```

## Resources

A produced at https://wiki.fulmo.org/index.php?title=Lightning_HackSprint.  
Thanks to [@emzy](https://twitter.com/emzy) for the original socat syntax.