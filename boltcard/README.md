# Bolt card setup using LNbits

## Tools used
* Card: NXP NTAG424 DNA https://zipnfc.com/nfc-pvc-card-credit-card-size-ntag424-dna.html
* Raspiblitz node running:
  * Core Lightning
  * LNbits with the Bolt Cards extension activated
* Boltcard NFC Card Creator Android app

## Preparation
### (optional) Run the latest experimental scripts of Raspiblitz
* `menu` -> `PATCH `
* `REPO`: raspiblitz
* `BRANCH`: dev

### (optional) To update LNbits to the latest commit in the master branch
* Run:
```
config.scripts/bonus.lnbits.com sync
```
### Expose LNbits on a public domain
* can use a cheap, minimal VPS tunneled from the node with Tailscale
* point an A-record with a subdomain to the public IPaddress of the VPS
* download Tailscale on the node and the VPS: https://tailscale.com/download/linux
* log in on both (consider using a dedicated github account)
* on the VPS set up nginx to forward a subdomain to the `TailscaleIP:LNbitsPORT` on the node: https://github.com/openoms/bitcoin-tutorials/tree/master/nginx

### Download the Boltcard NFC Card Creator Android app
 * https://play.google.com/store/apps/details?id=com.lightningnfcapp
 * https://github.com/boltcard/bolt-nfc-android-app

## Steps to set up a Bolt Card
* open LNbits on the public domain
* create a wallet and save the link
* add the Bolt Cards extension (to serve the boltcard API)
* open the extension and create a bolt card
* scan the QRcode with the keys with the Boltcard NFC Card Creator app
* write the keys on a blank card by touching it to the phone

The setup of the bolt card is complete!

Don't forget to fund the LNbits wallet backing the card to be able to pay.

## Test
* Blink
* Breez
* Wallet of Satoshi
* NFC enabled webwallet 
    * LNbits TPOS: https://clnbits.diynodes.com/tpos/gyZytJ3eLygXbe7EsJoi8C
    * BTCPay Server: https://tips.diynodes.com
* NFC enabled PoS terminals

Resources:
* https://www.boltcard.org/
* https://github.com/boltcard/boltcard
* https://github.com/boltcard/bolt-nfc-android-app
* https://github.com/lnbits/lnbits/tree/main/lnbits/extensions/boltcards
* Post on stacker.news: https://stacker.news/items/81920
