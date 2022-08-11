## PGP encryption

```
# work in an ephemeral directory in the RAM
mkdir /dev/shm/tmp
cd /dev/shm/tmp

# create the cleartext files with the secrets

## encrypt using GPG
# import the pubkey of the recipient with curl
curl https://keybase.io/${username}/key.asc | gpg --import
# encrypt the file
gpg --recipient ${username_or_email_or_PGPpubkey} --armor --output ${file_out} --encrypt ${file_in}
# same in short
gpg -ar ${username_or_email_or_PGPpubkey} -o ${file_out} -e ${file_in}

## encrypt using keybase (https://keybase.io/encrypt)
# using `keybase pgp pull` which
# imports to GPG key chain for you
keybase follow ${username}
keybase pgp pull ${username}
# encrypt
keybase pgp encrypt -i ${file_in} -o ${file_out} ${username}

# send the encrypted file(s) to the recipient(s)

# secure delete the directory
srm -r /dev/shm/tmp
```
