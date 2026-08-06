## SeedSigner + smartcard single seed multi-location backup scheme

SeedSigner is stateless by default. The seed can be backed up as a mnemonic,
SeedQR, or to a smartcard such as Satochip / SeedKeeper when using a compatible
smartcard reader.

Documentation:
* SeedSigner independent custody guide: <https://seedsigner.com/seedsigner-independent-custody-guide/>
* SeedSigner + Satochip guide: <https://planb.academy/tutorials/wallet/hardware/seedsigner-satochip-88d8cc3e-c0ac-4144-877f-4383828c27b8>

The SeedSigner device and smartcard reader are not secrets by themselves. The
secret material is the seed backup, the initialized smartcard, the smartcard
PIN, and the optional BIP39 passphrase.

This scheme assumes a Satochip signer card initialized with the seed. Use a
long random smartcard PIN and keep a backup of it. If using a BIP39 passphrase,
keep it separate from the seed backup.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* SeedSigner or any BIP39 compatible wallet
* Seed mnemonic (12/24 words) or SeedQR
* BIP39 passphrase

#### Full backup 2
* SeedSigner with smartcard reader or compatible wallet
* Satochip signer card initialized with the seed
* Satochip PIN
* BIP39 passphrase

---
### Packages for a 2-of-3 setup
#### Location 1
* Seed mnemonic (12/24 words) or SeedQR
* Satochip PIN

#### Location 2
* SeedSigner with smartcard reader
* Satochip signer card initialized with the seed
* BIP39 passphrase

#### Location 3
* SeedSigner with smartcard reader
* Satochip PIN
* BIP39 passphrase

---
### SeedKeeper note
If using a SeedKeeper card as a seed backup instead of a written mnemonic or
SeedQR, treat the SeedKeeper card as seed material protected by its own PIN.
Do a recovery test and compare the wallet fingerprint before relying on it.
