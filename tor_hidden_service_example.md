## Create a Tor Hidden Service
A simple example of creating and using a Tor Hidden Service.

Using SSH as an example, use any other name to be change the directory name.

* Install Tor:
  ```
  sudo apt install tor
  ```
* Edit the config file:
  ```
  sudo nano /etc/tor/torrc
  ```
* Create a v3 onion address
  sharing the internal ssh port (22) on the custom port 8080 of the .onion service:
  ```
  HiddenServiceDir /var/lib/tor/ssh/
  HiddenServiceVersion 3
  HiddenServicePort 8080 127.0.0.1:22
  ```
* Restart Tor:
  ```
  sudo systemctl restart tor
  ```
* List the files in the directory
  ```
  $ sudo ls -la /var/lib/tor/ssh/
  total 12
  drwx------ 1 debian-tor debian-tor 136 Jan 30 07:09 .
  drwx------ 1 debian-tor debian-tor 826 Jan 31 00:00 ..
  drwx------ 1 debian-tor debian-tor   0 Feb 11  2020 authorized_clients
  -rw------- 1 debian-tor debian-tor  63 Jan 30 07:09 hostname
  -rwx------ 1 debian-tor debian-tor  64 Feb 11  2020 hs_ed25519_public_key
  -rwx------ 1 debian-tor debian-tor  96 Feb 11  2020 hs_ed25519_secret_key
  ```
* Note the Hidden Service address:
  ```
  sudo cat /var/lib/tor/ssh/hostname
  ```
* For `ssh` over Tor install Tor on your client
  * Linux:
    ```
    sudo apt install tor
    ```
  * On mobile can use Termux:
    ```
    pkg install tor
    ```
    run Tor in a different window:  
    ```
    tor
    ```
    or in the background with:
    ```
    tor &
    ```
  * See this video for different Windows and MacOS: https://www.keepitsimplebitcoin.com/how-to-install-tor/

* SSH over Tor  
  in a Linux terminal use (set the custom port used for ssh):
  ```
  torsocks ssh -p8080 username@HiddenServiceAddress.onion
  ```

* If there is a website hosted on your .onion service use the [Tor Browser](https://www.torproject.org/) to open the address.

## Add client authorization (Optional)
A simple example of requiring authentication credential in order to connect to the onion service

* Install required packages:
  ```
  sudo apt install basez openssl
  ```
* Generate key:
  ```
  openssl genpkey -algorithm x25519 -out /tmp/k1.prv.pem
  ```
* Re-format key into base32 creating public and private keys:
  ```
  cat /tmp/k1.prv.pem | grep -v " PRIVATE KEY" | base64pem -d | tail --bytes=32 | base32 | sed 's/=//g' > /tmp/k1.prv.key
  openssl pkey -in /tmp/k1.prv.pem -pubout | grep -v " PUBLIC KEY" | base64pem -d | tail --bytes=32 | base32 | sed 's/=//g' > /tmp/k1.pub.key
  ```
* Note the private key (client):
  ```
  cat /tmp/k1.prv.key
  ```
* Note the public key: (server):
  ```
  cat /tmp/k1.pub.key
  ```
* Server config:
   * Create .auth file:
   ```
   sudo nano /var/lib/tor/ssh/authorized_clients/alice.auth
   ```
   * Edit .auth file:
   ```
   descriptor:x25519:<base32-pub-key>
   ```
* Client config for (choose one):
  * GUI service (thunderhub): 
    * Enter the private key noted above Tor Browser when prompted the [credential window](https://tb-manual.torproject.org/onion-services/).

  * Headless service (ssh):
    * Edit the config file:
    ```
    ClientOnionAuthDir /var/lib/tor/onion_auth/
    ```
    * Create .auth_private file:
    ```
    sudo nano /var/lib/tor/onion_auth/bob-ssh.auth_private
    ```
    * Edit .auth_private file
    ```
    <56-char-onion-addr-without-.onion-part>:descriptor:x25519:<base32-priv-key>
    ```
* Remove keys stored in /tmp:
  ```
  sudo rm -f /tmp/k1.pub.key /tmp/k1.prv.key /tmp/k1.prv.pem
  ```
* Restart Tor to apply changes (server and client):
  ```
  sudo systemctl restart tor@default
  ```

#### Notes:

* The SSL stripping attack is not applicable when the traffic does not leave the Tor network so usinga  self-hosted Hidden Service in the Tor Browser is not at risk. 
* Always make sure that the clearnet site you open in the Tor Browser uses SSL encryption (HTTPS).

#### Sources:

* [Tor Guide - Setup Onion Service](https://community.torproject.org/onion-services/setup/)
* [Tor Guide - Client Authorization](https://community.torproject.org/onion-services/advanced/client-auth/)
* [Mike Tigas bash script](https://gist.github.com/mtigas/9c2386adf65345be34045dace134140b) or [Suphanat Chunhapanya rust script](https://github.com/ppopth/torkeygen)
