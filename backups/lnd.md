## LND backup scheme
Notes on LND seed format:


### Components grouped together by the requirement for a full restore
#### Full backup 1
* Seed (24 words)
- Cypher phrase (passphrase)
#### Full backup 2 
- lnd folder (wallet.db + channel.db)
* wallet password

#### Location 1
- Seed (24 word)
- lnd folder (wallet.db + channel.db)

#### Location 2 
- Cypher phrase (passphrase)
* wallet password

#### Location 3
* Seed (24 words)
* wallet password
