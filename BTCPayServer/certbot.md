# Certbot commands

```
echo "Input your email:"
read EMAIL

echo "Input 3 subdomains separated with commas (eg: pay.example.com,tips.example.com,status.example.com)"
read SUBDOMAINS

firstDomain=$(echo $SUBDOMAINS|cut -d"," -f1)
```

* see details of a certificate
```
sudo openssl x509 -in /etc/letsencrypt/live/$firstDomain/fullchain.pem -text
```

* force renewal
```
sudo certbot certonly --force-renewal -a standalone -m $EMAIL --agree-tos -d $SUBDOMAINS --expand -n --pre-hook "service nginx stop" --post-hook "service nginx start"
```

* logs
```
sudo tail -n100 /var/log/letsencrypt/letsencrypt.log
```