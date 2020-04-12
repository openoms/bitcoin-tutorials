## Samourai Wallet single seed multi-location backup scheme
Documentation on Samourai Wallet recovery:  
<https://support.samourai.io/article/18-restore-your-samourai-wallet-with-your-secret-words>  
<https://support.samourai.io/article/8-restore-wallet-from-auto-backup-file>

In case of restoring the wallet in different software (eg. Electrum) check  
<https://walletsrecovery.org> for the derivation paths used.

Note that Samourai Wallet does not allow spaces in the passphrase.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Seed (12 words)
* Passphrase (without spaces)
#### Full backup 2 
* Backup file (encrypted text)
* Passphrase (without spaces)
#### Full backup 3
* Android device with the wallet loaded (locked with PIN codes)
    * use a secondary, dedicated device for backup 
    * have 2*8 digits PINs which are different from the primary device
    * have a locked bootloader with the latest security patches
* PIN codes to the Android Device AND Samourai Wallet
    * test if the phone and the wallet can be unlocked with the PINs even after a restart

---
### Packages for a 2-of-3 setup
#### Location 1
- Seed (12 words)
- Backup file (encrypted text)
- PIN codes to the Android Device AND Samourai Wallet

#### Location 2 
- Passphrase (without spaces)
- PIN codes to the Android Device AND Samourai Wallet 

#### Location 3
- Seed (12 words)
- Android device with the wallet loaded (locked with PIN codes)
