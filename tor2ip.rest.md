* create the service file:   
`# nano /etc/systemd/system/tor2ip8175.service`
    * Paste the following and fill in:
        * the VPS_PORT you want to use (facing the public) - in this example: 8175.
        * the TOR_HIDDEN_SERVICE_ADDRESS.onion
            * get the address with:
                * `sudo cat /mnt/hdd/tor/SERVICE_NAME/hostname`
        * The TOR_PORT the Hidden Service is using - in this example: 8080

    ```
    [Unit]
    Description=Tor2IP Tunnel Service
    After=network.target

    [Service]
    User=root
    Group=root
    ExecStart=/usr/bin/socat TCP4-LISTEN:8175,bind=0.0.0.0,fork SOCKS4A:localhost:TOR_HIDDEN_SERVICE_ADDRESS.onion:8080,socksport=9050
    StandardOutput=journal

    [Install]
    WantedBy=multi-user.target
    ```
* Enable and start the service:  
`# systemctl enable tor2ip8175`  
`# systemctl start tor2ip8175`

Setting up this Tor-to-IP tunnel service is now complete. You can carry on adding other services using different ports on the VPS.  
You should be able access the ports/services of the host computer through: VPS_IP_ADDRESS:VPS_PORT.
