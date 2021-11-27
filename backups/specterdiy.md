## SpecterDIY single seed multi-location backup scheme

The smartcard reader is part of the Specter Shield ([out of stock currently](https://specter.solutions/shop/)) or can be used as a USB extension.

Do not encrypt the secret on the smartcard to be able to restore in any other SpecterDIY device.
Use a long PIN for the smartcard. 8 or more digits are recommended.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* SpecterDIY hardware wallet with a smartcard reader
* Smartcard with the secret stored
* Smartcard PIN
* BIP39 passphrase
#### Full backup 2
* Any BIP39 compatible wallet
* Seed mnemonic (12/24 words)
* BIP39 passphrase

---
### Packages for a 2-of-3 setup
#### Location 1
* SpecterDIY hardware wallet with a smartcard reader
* Smartcard with the secret stored
* BIP39 passphrase

#### Location 2 
* SpecterDIY hardware wallet with a smartcard reader
* Smartcard PIN
* BIP39 passphrase
  
#### Location 3
* Seed mnemonic (12/24 words)