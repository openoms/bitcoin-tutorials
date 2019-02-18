
https://github.com/OpenBazaar/openbazaar-go/blob/master/docs/install-linux.md

cd $GOPATH/src/github.com/OpenBazaar/openbazaar-go
go run openbazaard.go init
go run openbazaard.go setapicreds
go run openbazaard.go start

go run $GOPATH/src/github.com/OpenBazaar/openbazaar-go/openbazaard.go start

https://api.docs.openbazaar.org/


To restore your shop from a backup copy your existing .openbazaar dir to /root/.openbazaar

To restore your OpenBazaar node only from the backup seed:
https://openbazaar.zendesk.com/hc/en-us/articles/360002820331-How-do-I-restore-my-OpenBazaar-wallet-from-seed-


Install on your desktop:
https://openbazaar.org/download/

sudo nano /mnt/dietpi_userdata/openbazaar/config 
sudo nano /root/.openbazaar/config 
cd /mnt/dietpi_userdata/go/src/github.com/OpenBazaar/openbazaar-go/

https://freedomnode.com/blog/80/how-to-install-and-configure-new-openbazaar-2-0-on-linux-and-mac-os-x


root@DietPi:/mnt/dietpi_userdata/go/src/github.com/OpenBazaar/openbazaar-go# go run openbazaard.go -h
Usage:
  openbazaard [OPTIONS] <command>

Application Options:
  -v, --version  Print the version number and exit

Help Options:
  -h, --help     Show this help message

Available commands:
  convert          convert this node to a different coin type
  decryptdatabase  decrypt your database
  encryptdatabase  encrypt your database
  gencerts         Generate certificates
  init             initialize a new repo and exit
  restart          restart the server
  restore          restore user data
  setapicreds      set API credentials
  start            start the OpenBazaar-Server
  status           get the repo status
  stop             shutdown the server and disconnect

