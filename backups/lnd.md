## LND single seed multi-location backup scheme
Notes on LND wallet recovery: <https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md>  
Notes on LND seed format (different from Bip39 or Electrum): <https://github.com/lightningnetwork/lnd/tree/master/aezeed>

### Components grouped together by the requirement for a full restore

#### Full backup 1
* Seed (24 words)
* Cypher Phrase (passphrase)
#### Full backup 2 
* LND folder with the !!latest!! state (wallet.db + channel.db)
* Wallet Unlock Password

### Packages for a 2-of-3 setup

#### Location 1
* Seed (24 word)
* LND folder (wallet.db + channel.db)

#### Location 2 
* Cypher Phrase (passphrase)
* Wallet Unlock Password

#### Location 3
* Seed (24 words)
* Wallet Unlock Password
