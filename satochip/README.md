# Get started with Satochip

What you need to access the wallet stored on the card:
* the smartcard loaded with the Satochip java applet and initialized (this was likely done by the one handing the card to you)
+ a smartcard reader (here an ACS ACR39U-N1 PocketMate II USB)
* a computer with a USB port capable to run:
  - [TailsOS](https://tails.net/) (can be used offline, but to see new transactions and the balance needs an internet connection)
  - Debian 12
  - Windows 10
  - other operating systems will likely work, just not tested

## Connect the Satochip Card
* open the Smartcard Reader by turning

  <img src="./card-and-reader01.png" height="200">
  <img src="./card-and-reader02.png" height="200">

* plug in the Card to the Reader with the chip facing up
* connect the Reader to a USB port
* the Reader will start flashing

  <img src="./card-and-reader03.png" height="200">
  <img src="./card-and-reader04.png" height="200">

* remove other smartcards (like a Yubikey) temporarily

## Download and run Sparrow Wallet

* find the files for your operating system at [sparrowwallet.com/download](https://sparrowwallet.com/download/)
* follow the steps to verify the downloaded binary. Can use Sparrow Wallet itself to do the verification once installed.
* if you don't have your own server use one public server which you know, eg.: `electrum.diynodes.com`

## Import the Satochip wallet to Sparrow Wallet

* select `New Wallet`

  <img src="load-satochip-to-sparrow01.png" height="600">

* type a name and `Create Wallet`

  <img src="load-satochip-to-sparrow02.png" height="600">

* select `Airgapped Hardware Wallet`

  <img src="load-satochip-to-sparrow03.png" height="600">

* click `Import` next to `Satochip`

  <img src="load-satochip-to-sparrow04.png" height="600">

* enter the PIN code then click `Import` again

  <img src="load-satochip-to-sparrow05.png" height="600">

* can see the details for the default derivation path. Save with `Apply`.

  <img src="load-satochip-to-sparrow06.png" height="600">

* it is optional to set a password to protect the read-only wallet on saved on the desktop.

* select the `Transaction` tab on the left to see the balance and transaction history of the wallet on the card.

+ make sure to wait for `Finished loading`

  <img src="load-satochip-to-sparrow07.png" height="600">

* in case transactions are missing despite a connected server can try increase the `Gap limit` in `Settings` -> `Advanced`

* refer to the Sparrow Wallet documentation to transact using your Satochip: https://sparrowwallet.com/docs/coldcard-wallet.html#sending-bitcoin

## Reference:
* find the original Satochip cards at: [satochip.io/product/satochip](https://satochip.io/product/satochip/)

* for the DIY version see this [gist](https://gist.github.com/openoms/510b2876cab19e15c4190456ea8aad82#file-satochip-javacard-applet-install)

* the Smartcard Reader pictured: ACS ACR39U-N1 PocketMate II USB Smart Card Reader
  * [amazon.co.uk/dp/B0758TS5JR](https://www.amazon.co.uk/dp/B0758TS5JR/)
  * [aliexpress.com/item/1005002034557322.html](https://www.aliexpress.com/item/1005002034557322.html)

* the Card pictured: JCOP Chip Card Dual Interface Chip Magnetic Stripe Java Card J3H145 (no NFC)
  * [alibaba.com/product-detail/JCOP-Dual-Interface-Support-RSA4096-ECC_1600070838098.html](https://www.alibaba.com/product-detail/JCOP-Dual-Interface-Support-RSA4096-ECC_1600070838098.html)
