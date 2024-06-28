## SeedXOR multi-location backup scheme
Full documentation: [seedxor.com/](https://seedxor.com/)

Existig seeds can be broken up with seedXOR or can be used as components of a new scheme.
If there was a BIP39 passphase used keep a copy of the passphrase on every location.

Currently the scheme can be used on a [ColdCard](https://github.com/Coldcard/firmware/blob/master/docs/seed-xor.md) and is planned to be implemented in [SeedSigner](https://github.com/SeedSigner/seedsigner/issues/43).
The seed can also be calculated manually so the ColdCard is not strictly necessary for recovery

---
### Components required for a full restore
* Coldcard or manual calculation + any BIP32 compatible wallet
* Seed1
* Seed2
* Seed3

---
### Packages for a 2-of-3 setup
#### Location 1
* Seed1
* Seed2

#### Location 2 
* Seed2
* Seed3

#### Location 3
* Seed1
* Seed3
