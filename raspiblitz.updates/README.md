## Automated update scripts for the RaspiBlitz and compatible systems

## Bitcoin Core Updates

### [v0.21.0](/raspiblitz.updates/bitcoincore.update.v0.21.0.sh)
* On RaspiBlitz v1.6.3 the peers won't be diplayed correctly.  
  Use: `bitcoin-cli getnetworkinfo`
* To download, check and run in the RaspiBlitz terminal:  
    ```
    #download:
    wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/raspiblitz.updates/bitcoincore.update.v0.21.0.sh
    #inspect the script:
    cat bitcoincore.update.v0.21.0.sh
    #run:
    bash bitcoincore.update.v0.21.0.sh
    ```

### [v0.20.0](/raspiblitz.updates/bitcoincore.update.v0.20.0.sh)
* Not compatible with LND under v0.8.1, use with RaspiBlitz v1.4 or update LND first.
* To download and run with a single line paste to the RaspiBlitz terminal:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/raspiblitz.updates/bitcoincore.update.v0.20.0.sh && bash bitcoincore.update.v0.20.0.sh`

### [v0.19.1](/raspiblitz.updates/bitcoincore.update.v0.19.1.sh)
* Not compatible with LND under v0.8.1, use with RaspiBlitz v1.4 or update LND first.
* To download and run with a single line paste to the RaspiBlitz terminal:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/raspiblitz.updates/bitcoincore.update.v0.19.1.sh && bash bitcoincore.update.v0.19.1.sh`

## LND updates
Find in: [https://github.com/openoms/lightning-node-management](https://github.com/openoms/lightning-node-management/blob/master/lnd.updates/README.md)