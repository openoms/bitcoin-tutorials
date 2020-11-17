# Phone as a wallet

A guide to store bitcoin on a clean Android or iPhone secured with multisignature in the Blockstream Green Wallet.  
A recommendation to people who are looking into how to take custody of their first satoshis and not running their own node yet.

## Why a phone?
* generic hardware (there is no suggestion of it containing valuable keys)
* minimised supply chain attack (many are used without bitcoin involved)
* robust architecture with a secure chip (in the SoC or separate as the [Titan M](https://www.androidauthority.com/titan-m-security-chip-915888/) in Google Pixels from 3/3A onwards)
* capable of connecting to the internet and initiate a bitcoin transaction (vs a hardware wallet needs another computer and additional software)

## Why the Blockstream Green wallet?
* [open source](https://github.com/Blockstream), [reproducible](https://walletscrutiny.com/android/com.greenaddress.greenbits_android_wallet/) build
* available on multiple platforms: Android, iOS and desktops
* easy, self explanatory interface and [detailed documentation](https://help.blockstream.com/hc/en-us/categories/900000056183-Blockstream-Green/)
* unique [Two-Factor Authentication (2FA)](https://help.blockstream.com/hc/en-us/articles/900001388366-What-does-Blockstream-Green-s-multisig-protect-from-) capability
* note that this is not a private way to use bitcoin since the wallet is connecting to the server of Blockstream

## Phone specs
* use a dedicated device to minimise the attack surface 
* can be a used phone sitting in the drawer, but the more recent model it is the better
* locked bootloader (true to all factory firmwares - see the [notes on custom firmwares below](#using-a-custom-firmware))
* encrypted storage - default on iPhones and newer Androids when a screen lock with a PIN is set

## Steps done on the phone
* set up in a safe environment and network
* apply the latest security update
* perform a factory reset
* apply the most strict privacy settings and log in to only the bare minimum services
* apply the strongest possible PIN or passphrase to the lock screen, store it in a password manager, avoid biometrics
* download the Blockstream Green wallet from the [App Store](https://apps.apple.com/us/app/green-bitcoin-wallet/id1402243590) / [Play Store](https://play.google.com/store/apps/details?id=com.greenaddress.greenbits_android_wallet) / [F-droid](https://f-droid.org/en/packages/com.greenaddress.greenbits_android_wallet/) / [GitHub](https://github.com/Blockstream/green_android/releases)
* [set up Green Wallet](https://help.blockstream.com/hc/en-us/articles/900002327003-How-do-I-create-a-new-wallet-) with the 6 character PIN and [Two-Factor Authentication (2FA)](https://help.blockstream.com/hc/en-us/articles/900001388366-What-does-Blockstream-Green-s-multisig-protect-from-)
with email and Google Authenticator

## Further advice
* Set up a password manager. [Bitwarden](https://bitwarden.com/) is a good open-source option with free, encrypted cloud storage and self hosting ability.
* the Time-Based One Time Password (TOTP) authentication (Google Authenticator / Authy) is the best 2FA option for most. Don't run it on the same device and store the backup secret in a password manager
* if using email don't login to the email account on the same device - use a dedicated, unique, pseudonymous email with end-to-end encrypted providers like [Protonmail](https://protonmail.com/) or [TutaNota](https://tutanota.com/) - store the login in a password manager
* carefully note the 24 words seed down to paper ([pencil lasts more then ink](https://en.bitcoin.it/wiki/Seed_phrase#Paper_and_Pencil_Backup)) / etch into metal and store in a safe place
* it is the safest to store the phone switched off (the encryption key leaves the memory and not only protected by the lockscreen)
* the 2FA creates a 2-of-2 multisig with Blockstream which [can only be accessed after 365 days with only the seed](https://help.blockstream.com/hc/en-us/articles/900001536126-I-ve-lost-access-to-my-2FA-how-do-I-access-my-funds-) (in case of losing access to the 2FA or Blockstream disappearing)
* connect always through Tor, it is built in to Green and helps avoiding connecting the IP address with the bitcoin stored while querying Blockstream's server

## Watch-only wallet
* on an other device (can be a day-to-day used phone or desktop) set up Blockstream Green in [watch only mode](https://help.blockstream.com/hc/en-us/articles/900003101806-What-is-watch-only-mode-)
* the watch only wallet can be used to generate addresses and monitor the funds on the blockchain
* there is no risk of losing the funds if the watch-only device is lost, stolen or compromised (it only contains the public keys, not touching the private ones)
* note the privacy implications of the labels, addresses and xpub being stored on Blockstream's server

## Using a custom firmware
* a locked bootloader is a must - check on Android with:   
`fastboot oem device-info`  
* Two hardened, privacy focused custom firmwares which allow relocking the bootloader:
  * [GrapheneOS](https://grapheneos.org/) compatible with Pixel devices 
  * [CalyxOS](https://calyxos.org/) for Pixels and the Xiaomi Mi A2

## Resources
* [Video setup](https://help.blockstream.com/hc/en-us/categories/900000056183-Blockstream-Green/)

* [Blockstream Green docs](https://help.blockstream.com/hc/en-us/categories/900000056183-Blockstream-Green/)

* [GreenAddress Recovery](https://github.com/greenaddress/garecovery)

* [How secure is full-disk encryption technology on LineageOS, or Android phones in general?](https://security.stackexchange.com/questions/210994/how-secure-is-full-disk-encryption-technology-on-lineageos-or-android-phones-in)

## Level up
* [Single seed multi-location backup schemes](https://github.com/openoms/bitcoin-tutorials/blob/master/backups/README.md)  
    The aim is to create 3 packages of cryptographically secure backups where the funds cannot be recovered from any single package, but can be recovered with the combination of any two.
    Can be thought of as a physical 2-of-3 multisig solution.

* [10x Security Bitcoin Guide](https://btcguide.github.io/)  
    How to store bitcoin without any single point of failure. 
    Multisig security is a difference in kind and not in degree. It affords you the ability to avoid loss while making 1 (or more) catastrophic failures in securing your bitcoin. By using a security system that is fault-tolerant, you can move much faster (with less caution) through each step and still attain far higher levels of security vs any single-key system. This guide will show you how. 