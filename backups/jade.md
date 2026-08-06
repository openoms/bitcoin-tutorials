## Blockstream Jade single seed multi-location backup scheme

Documentation:
* Jade stateless signing mode: <https://help.blockstream.com/blockstream-jade/add-more-security-functionality/use-jade-as-a-stateless-signing-device>
* Jade Plus SeedQR mode: <https://help.blockstream.com/blockstream-jade/use-jade-air-gapped/access-jade-plus-air-gapped-with-seedqr>

Jade can be used either as an initialized hardware wallet protected by a PIN, or
as a stateless signer where the seed is loaded temporarily from a recovery
phrase or SeedQR. SeedQR is equivalent to the seed mnemonic and must be treated
as seed material.

This scheme only makes sense when using a BIP39 passphrase. Without a
passphrase the seed mnemonic or SeedQR is enough to restore the wallet from a
single location.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Jade or any BIP39 compatible wallet
* Seed mnemonic (12/24 words) or SeedQR
* BIP39 passphrase

#### Full backup 2
* Initialized Jade
* Jade PIN
* BIP39 passphrase

---
### Packages for a 2-of-3 setup
#### Location 1
* Seed mnemonic (12/24 words) or SeedQR
* Jade PIN

#### Location 2
* Initialized Jade
* BIP39 passphrase

#### Location 3
* Jade PIN
* BIP39 passphrase
