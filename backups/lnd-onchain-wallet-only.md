# LND single seed multi-location backup scheme for the onchain funds only

The aim is to create a redundant backup where the secret can be restored from any two locations.  
If someone in charge bootstrapping an LND node can use this method to share the parts with 3 other people who will not be able to restore the wallet alone.

The 24 words seed should not be split in more than 2 parts as 8 words are close to be brute-forceable.

For the Cypher Phrase a good option is to use 12 words from the standard wordlist to ease the offline backup and keep the security of parts roughly the same.  
An example to generate 12 words separated by spaces using a [diceware](https://github.com/ulif/diceware#diceware) sourcing the entropy from  `/dev/urandom` :
```
$ sudo apt install diceware
$ diceware -n 12 -d' ' --no-caps
```
Note that the password asked first when generating the wallet is only used to encrypt the file and not relevant to the secret itself.

More on LND wallet recovery: <https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md>  
LND seed format (different from Bip39 or Electrum): <https://github.com/lightningnetwork/lnd/tree/master/aezeed>  
Test at https://guggero.github.io/cryptography-toolkit/#!/aezeed  

Include the Node ID on all backup locations. It is derived from the bip32 root key (encoded by the Seed + Cypher Phrase) so it can be used to identify the backup and test the successful recovery.
Obtain the Node ID with
```
$ lncli getinfo | grep identity_pubkey
```

---
## Full backup required to restore
* Seed (24 words - split in two)
  * Seed words #1 - #12
  * Seed words #13 - #24
* Cypher Phrase (aka passphrase)
* Node ID (for verification)
---
## Packages for a 2-of-3 setup
### Location 1
* Node ID
* Seed words #1 - #12
* Cypher Phrase

### Location 2
* Node ID
* Seed words #13 - #24
* Cypher Phrase

### Location 3
* Node ID
* Seed words #1 - #12
* Seed words #13 - #24
