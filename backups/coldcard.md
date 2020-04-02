## ColdCard single seed multi-location backup scheme
Original idea by [@KollerTobias](https://twitter.com/KollerTobias) and [@21isenough](https://github.com/21isenough/).  
Documentation of Coldcard backups: <https://coldcardwallet.com/docs/backups>  
The scheme only works if the seed is not locked down to a passphase:
<https://coldcardwallet.com/docs/passphrase>  
In this case the passphrase is not tied to a PIN,
but needs to be written in the CC every time the wallet is opened.

The ColdCards should be stored uninitialized, best to be freshly acquired in the tamper resistant package from the manufacturer (<https://coldcardwallet.com>) to minimize the risk or evil-maid and supply-chain attacks.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Seed mnemonic (12/18/24 words)
* Passphrase
#### Full backup 2
* Backupfile (.7z archive on the SD)
* Backup password (12 words)
* Passphrase

---
### Packages for a 2-of-3 setup
#### Location 1
- Seed mnemonic (12/18/24 words)
- Backup password (12 words)
- Backupfile (.7z archive on the SD)

#### Location 2 
- Passphrase (BIP39)
- Backupfile (.7z archive on the SD)

#### Location 3
- Passphrase (BIP39)
- Backup password (12 words)