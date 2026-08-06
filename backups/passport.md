## Foundation Passport single seed multi-location backup scheme

Documentation of Passport encrypted microSD backups:
<https://docs.foundation.xyz/backups/passport-core/>

By default, Passport creates an encrypted microSD backup containing the seed
words and device settings. The encrypted backup needs the microSD card and the
20 digit Backup Code for recovery. Store them separately.

If a BIP39 passphrase is used, it must be backed up separately. The passphrase
is not a replacement for the Passport Backup Code.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Any BIP39 compatible wallet or Passport
* Seed mnemonic (12/24 words)
* BIP39 passphrase

#### Full backup 2
* Passport
* Encrypted microSD backup
* Backup Code (20 digits)
* BIP39 passphrase

---
### Packages for a 2-of-3 setup
#### Location 1
* Seed mnemonic (12/24 words)
* Backup Code (20 digits)
* Encrypted microSD backup

#### Location 2
* Passport
* BIP39 passphrase
* Encrypted microSD backup

#### Location 3
* Passport
* BIP39 passphrase
* Backup Code (20 digits)
