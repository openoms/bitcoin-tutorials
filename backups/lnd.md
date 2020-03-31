## LND single seed multi-location backup scheme
Notes on LND wallet recovery: <https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md>  
Notes on LND seed format (different from Bip39 or Electrum): <https://github.com/lightningnetwork/lnd/tree/master/aezeed>

### Components grouped together by the requirement for a full restore

#### Full backup 1
* Seed (24 words)
- Cypher phrase (passphrase)
#### Full backup 2 
- lnd folder (wallet.db + channel.db)
* wallet password

### Packages for a 2-of-3 setup

#### Location 1
- Seed (24 word)
- lnd folder (wallet.db + channel.db)

#### Location 2 
- Cypher phrase (passphrase)
* wallet password

#### Location 3
* Seed (24 words)
* wallet password
