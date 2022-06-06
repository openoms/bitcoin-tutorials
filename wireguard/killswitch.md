# Forward all traffic through a wireguard VPN

* VPN: https://lnvpn.net/

* How to: https://www.wireguard.com/netns/

* Kill Switch with PostUp and PreDown WG syntax https://www.ivpn.net/knowledgebase/linux/linux-wireguard-kill-switch/

* Simple ufw killswitch from https://www.reddit.com/r/WireGuard/comments/bpmssc/comment/envrhu2
    ```
    another option is to create 2 bash scripts that make use of ufw.

    firewall.sh (change tun0 to what ever your wireguard interface is you can find it with "ifconfig" probably has "wg" in it somewhere)

        sudo ufw reset

        sudo ufw default deny incoming

        sudo ufw default deny outgoing

        sudo ufw allow out on tun0 from any to any

        sudo ufw enable

    And unfirewall.sh

        sudo ufw reset

        sudo ufw default deny incoming

        sudo ufw default allow outgoing

        sudo ufw enable

    make them both executable with chmod. then when you want the killswitch on "sudo bash firewall.sh" then you can test it by disconnecting from wireguard and ur internet shouldnt be working.

    and when you want to turn it off just run unfirewall.sh
    ```