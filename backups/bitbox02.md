## BitBox02 single seed multi-location backup scheme

Documentation of BitBox02 microSD backups:
<https://support.bitbox.swiss/en_US/microsd-card/how-to-create-bitbox02-microsd-backup>

The BitBox02 microSD backup is not encrypted with the device password.
Treat the microSD card as equivalent to the seed mnemonic and do not insert it
into a computer or phone.

The optional BIP39 passphrase is not stored in the microSD backup.
This scheme only makes sense when using a BIP39 passphrase. Without a
passphrase the seed mnemonic or microSD backup is enough to restore the wallet
from a single location.

Use a strong device password and a strong BIP39 passphrase. Label the backups
clearly to avoid confusing the device password with the BIP39 passphrase.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Any BIP39 compatible wallet or BitBox02
* Seed mnemonic (12/18/24 words) or BitBox02 microSD backup
* BIP39 passphrase

#### Full backup 2
* BitBox02
* Device password
* BIP39 passphrase

---
### Packages for a 2-of-3 setup
#### Location 1
* Seed mnemonic (12/18/24 words) or BitBox02 microSD backup
* Device password

#### Location 2
* BitBox02
* BIP39 passphrase

#### Location 3
* Device password
* BIP39 passphrase
