# Forward ports with a reverse SSH tunnel

## Advantages: 
* no port forwarding needed on the LAN of the host
* encrypted connection
* hides the IP of the host from the public

## Requirements:
* a Virtual Private Server (VPS) - eg. a minimal package on Lunanode for ~3.5$/month
* root access on the VPS - only root can forward ports under no. 1000
* ssh access to the host computer (where the ports will be forwarded from)

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

## Working on the VPS

* login as root or run:  
`$ sudo su -`

* edit the sshd config:  
`# nano /etc/ssh/sshd_config`

    * make sure these entries are active (uncommented, meaning there is no `#` at the beggining of the line).  
Can just paste these on the end of the file:
    ```
    RSAAuthentication yes
    PubkeyAuthentication yes
    GatewayPorts yes
    AllowTcpForwarding yes
    ClientAliveInterval 60
    ```
    CTRL+O, ENTER to save, CTRL+X to exit.
 
* restart the sshd service (WARNING: you can lose access at this point if the config is wrong):  
`# systemctl restart sshd`

## Back to the host computer

### Set up a systemd service

* create the service file:   
`# nano /etc/systemd/system/autossh-tunnel.service`

    * Paste the following and fill in the VPS_IP_ADDRESS.  
Add or remove ports as required.

    ```
    [Unit]
    Description=AutoSSH tunnel service
    After=network.target

    [Service]
    User=root
    Group=root
    Environment="AUTOSSH_GATETIME=0"
    ExecStart=/usr/bin/autossh -C -M 0 -v -N -o "ServerAliveInterval=60" -R 9735:localhost:9735 -R 443:localhost:443 -R 80:localhost:80 root@VPS_IP_ADDRESS
    StandardOutput=journal

    [Install]
    WantedBy=multi-user.target
    ```
* Enable and start the service:  
`# systemctl enable autossh-tunnel`  
`# systemctl start autossh-tunnel`

* The port forwarding with a reverse ssh-tunnel is now complete. 
You should be able access the ports/services of the host computer through the IP of the VPS.

## Monitoring

* Check if there are any errors on the host computer:  
`# sudo journalctl -f -n 20  -u autossh-tunnel`
    * Look for the lines:
    ```
    debug1: Authentication succeeded (publickey).
    debug1: Remote connections from LOCALHOST:9735 forwarded to local address localhost:9735
    debug1: Remote connections from LOCALHOST:443 forwarded to local address localhost:443
    debug1: Remote connections from LOCALHOST:80 forwarded to local address localhost:80
    debug1: remote forward success for: listen 9735, connect localhost:9735
    debug1: remote forward success for: listen 443, connect localhost:443
    debug1: remote forward success for: listen 80, connect localhost:80
    debug1: All remote forwarding requests processed
    ```

* To check if tunnel is active on the VPS:  
`# netstat -tulpn`

    * Look for the lines:
    ```
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
    tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      7694/sshd: root     
    tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      7694/sshd: root     
    tcp        0      0 0.0.0.0:9735            0.0.0.0:*               LISTEN      7694/sshd: root     
    tcp6       0      0 :::80                   :::*                    LISTEN      7694/sshd: root     
    tcp6       0      0 :::443                  :::*                    LISTEN      7694/sshd: root     
    tcp6       0      0 :::9735                 :::*                    LISTEN      7694/sshd: root     
    ```

## Resources

https://github.com/rootzoll/raspiblitz/blob/master/FAQ.md#how-to-setup-port-forwarding-with-a-ssh-tunnel

https://stadicus.github.io/RaspiBolt/raspibolt_21_security.html#login-with-ssh-keys
