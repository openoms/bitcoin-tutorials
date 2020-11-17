# Phone as a wallet

How to store bitcoin on a clean Android or iPhone secured with multisignature in the Blockstream Green Wallet

A recommendation to people who are looking into how to take custody of their first satoshis and not running their own node yet

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

## Phone specs
* use a dedicated device to minimise the attack surface (can be a used phone sitting in the drawer, but the most recent model it is the better)
* locked bootloader (true to all factory firmwares - see the [notes on custom firmwares below](#using-a-custom-firmware))
* encrypted storage - default on iPhones and newer Androids when a PIN screen lock is set

## Steps done on the phone
* set up in a safe environment and network
* apply the latest security update
* perform a factory reset
* apply the most strict privacy settings and log in to only the bare minimum services
* apply the strongest possible PIN or passphrase to the lock screen (store in a password manager), avoid biometrics
* download the Blockstream Green wallet from the [App Store](https://apps.apple.com/us/app/green-bitcoin-wallet/id1402243590) / [Play Store](https://play.google.com/store/apps/details?id=com.greenaddress.greenbits_android_wallet) / [F-droid](https://f-droid.org/en/packages/com.greenaddress.greenbits_android_wallet/) / [GitHub](https://github.com/Blockstream/green_android/releases)
* set up Green Wallet with the 6 character PIN and [Two-Factor Authentication (2FA)](https://help.blockstream.com/hc/en-us/articles/900001388366-What-does-Blockstream-Green-s-multisig-protect-from-)

## Further advice
* if using email don't login to the email account on the same device - use a dedicated, unique, pseudonymous email with end-to-end encrypted providers like [Protonmail](https://protonmail.com/) or [TutaNota](https://tutanota.com/)
* if using TOTP authentication (Google Authenticator / Authy) don't store it on the same device
* always connect through Tor, it is built in to Green (helps avoiding connecting the IP address with the bitcoin stored while querying Blockstream's server)
* carefully note the 24 words seed down to paper ([pencil lasts more then ink](https://en.bitcoin.it/wiki/Seed_phrase#Paper_and_Pencil_Backup)) / etch into metal and store in a safe place
* it is the safest to store the phone switched off (the encryption key leaves the memory and not only protected by the lockscreen)
* the 2FA creates a 2-of-2 multisig with Blockstream which [can only be accessed after 365 days with only the seed](https://help.blockstream.com/hc/en-us/articles/900001536126-I-ve-lost-access-to-my-2FA-how-do-I-access-my-funds-) (in case of losing access to the 2FA or Blockstream disappearing)

## Watch-only wallet
* on an other device (can be a day-to-day used phone or desktop) set up Blockstream Green in [watch only mode](https://help.blockstream.com/hc/en-us/articles/900003101806-What-is-watch-only-mode-)
* the watch only wallet can be used to generate addresses and monitor the funds on the blockchain.
* there is no risk of losing the funds if the watch-only device is lost/stolen/compromised (it only contains the public keys, not touching the private ones)

## Using a custom firmware
* a locked bootloader is a must - check on Android with:   
`fastboot oem device-info`  
* Two hardened, privacy focused custom firmwares which allow relocking the bootloader:
  * [GrapheneOS](https://grapheneos.org/) compatible with Pixel devices 
  * [CalyxOS](https://calyxos.org/) for Pixels and the Xiaomi Mi A2

## More reading:

* [Blockstream Green docs](https://help.blockstream.com/hc/en-us/categories/900000056183-Blockstream-Green/)

* [How secure is full-disk encryption technology on LineageOS, or Android phones in general?](https://security.stackexchange.com/questions/210994/how-secure-is-full-disk-encryption-technology-on-lineageos-or-android-phones-in)

* [GreenAddress Recovery](https://github.com/greenaddress/garecovery)