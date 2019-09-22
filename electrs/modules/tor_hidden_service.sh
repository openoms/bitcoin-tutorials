# Hidden Service for electrs if Tor active
source /mnt/hdd/raspiblitz.conf
if [ "${runBehindTor}" = "on" ]; then
    isElectrsTor=$(sudo cat /etc/tor/torrc 2>/dev/null | grep -c 'electrs')
    if [ ${isElectrsTor} -eq 0 ]; then
        echo "
        # Hidden Service for Electrum Server
        HiddenServiceDir /mnt/hdd/tor/electrs
        HiddenServiceVersion 3
        HiddenServicePort 50001 127.0.0.1:50001
        " | sudo tee -a /etc/tor/torrc

        sudo systemctl restart tor
        sudo systemctl restart tor@default
    fi
    TOR_ADDRESS=$(sudo cat /mnt/hdd/tor/electrs/hostname)
    echo ""
    echo "***"
    echo "The Tor Hidden Service address for electrs is:"
    echo "$TOR_ADDRESS"
    echo "***"
    echo "" 
fi