## Wasabi Wallet single seed multi-location backup scheme
Documentation on [Wasabi Wallet recovery](https://docs.wasabiwallet.io/using-wasabi/WalletRecovery.html), [with Electrum](https://docs.wasabiwallet.io/using-wasabi/RestoreElectrum.html), [in-built password finder](https://docs.wasabiwallet.io/using-wasabi/PasswordFinder.html), [lost password strategy](https://docs.wasabiwallet.io/using-wasabi/LostPassword.html).

In case of restoring the wallet in different software (eg. Electrum) check [Wallets Recovery](https://walletsrecovery.org) for the derivation paths used.
[Wasabi uses](https://docs.wasabiwallet.io/FAQ/FAQ-UseWasabi.html#what-derivation-paths-does-wasabi-use) `m/84'/0'/0', and due to the CoinJoin, the gap limit should be set to at least 100. 

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Seed (12 words)
* Passphrase (BIP39)
#### Full backup 2 
* Backup file (encrypted text)
* Passphrase (BIP39)
#### Full backup 3
* Laptop with Wasabi installed and wallet files (encrypted text)
* Password to laptop / disk encryption
* Passphrace (BIP39)

---
### Packages for a 2-of-3 setup
#### Location 1
- Seed (12 words)
- Backup file (encrypted text)
- Password for laptop / disk encryption

#### Location 2 
- Passphrase (BIP39)
- Password for laptop / disk encryption

#### Location 3
- Seed (12 words)
- Laptop with Wasabi installed and wallet files (encrypted text)
