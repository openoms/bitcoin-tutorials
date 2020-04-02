## LND single seed multi-location backup scheme
Notes on LND wallet recovery: <https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md>  
Notes on LND seed format (different from Bip39 or Electrum): <https://github.com/lightningnetwork/lnd/tree/master/aezeed>

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Seed (24 words)
* Cypher Phrase (passphrase)
* Static Channel Backup (channel.backup) 
  * needs to be updated to include every new channel and recovery requires the peers to be online

#### Full backup 2 
* LND folder with the !!**latest**!! state (wallet.db + channel.db) 
  * requires to have physical (screen and keyboard) or remote SSH access to the node (can be a Tor Hidden Service address for the port 22)
* Wallet Unlock Password 
  * include logins and/or the SSH password to allow access to the node

---
### Packages for a 2-of-3 setup
#### Location 1
* Seed (24 word)
* Static Channel Backup (channel.backup)
* LND folder (wallet.db + channel.db)

#### Location 2 
* Cypher Phrase (passphrase)
* Wallet Unlock Password

#### Location 3
* Seed (24 words)
* Static Channel Backup (channel.backup)
* Wallet Unlock Password