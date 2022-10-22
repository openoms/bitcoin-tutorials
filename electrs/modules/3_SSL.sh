# A script to set up the Electrum Server in Rust on the RaspiBlitz to connect over SSL to Eclair and Electrum wallet
# Sets up the automatic start of nginx and certbot

# To download and run:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/3_Nginx_and_Certbot_for_SSL.sh && bash 3_Nginx_and_Certbot_for_SSL.sh

echo ""
echo "***"
echo "installing Nginx"
echo "***"
echo ""

sudo apt-get install -y nginx
sudo /etc/init.d/nginx start

echo ""
echo "***"
echo "Create a self signed SSL certificate"
echo "***"
echo ""

#https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes
#https://stackoverflow.com/questions/8075274/is-it-possible-making-openssl-skipping-the-country-common-name-prompts

echo "
[req]
prompt=no
default_bits       = 2048
default_keyfile    = localhost.key
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_ca

[req_distinguished_name]
countryName                 = Country Name (2 letter code)
countryName_default         = US
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = New York
localityName                = Locality Name (eg, city)
localityName_default        = Rochester
organizationName            = Organization Name (eg, company)
organizationName_default    = localhost
organizationalUnitName      = organizationalunit
organizationalUnitName_default = Development
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_default          = localhost
commonName_max              = 64

[req_ext]
subjectAltName = @alt_names

[v3_ca]
subjectAltName = @alt_names

[alt_names]
DNS.1   = localhost
DNS.2   = 127.0.0.1
" | sudo tee /mnt/hdd/electrs/localhost.conf

cd /mnt/hdd/electrs
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config localhost.conf

sudo cp localhost.crt /etc/ssl/certs/localhost.crt
sudo cp localhost.key /etc/ssl/private/localhost.key

echo ""
echo "***"
echo "Setting up nginx.conf"
echo "***"
echo ""

isElectrs=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'upstream electrs')
if [ ${isElectrs} -gt 0 ]; then
        echo "electrs is already configured with Nginx. To edit manually run \`sudo nano /etc/nginx/nginx.conf\`"

elif [ ${isElectrs} -eq 0 ]; then

        isStream=$(sudo cat /etc/nginx/nginx.conf 2>/dev/null | grep -c 'stream {')
        if [ ${isStream} -eq 0 ]; then

        echo "
stream {
        upstream electrs {
                server 127.0.0.1:50001;
        }
        server {
                listen 50002;
                proxy_pass electrs;
                ssl_certificate /etc/ssl/certs/localhost.crt;
                ssl_certificate_key /etc/ssl/private/localhost.key;
                ssl_session_cache shared:SSL-electrs:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

        elif [ ${isStream} -eq 1 ]; then
                sudo truncate -s-2 /etc/nginx/nginx.conf
                echo "

        upstream electrs {
                server 127.0.0.1:50001;
        }
        server {
                listen 50002;
                proxy_pass electrs;
                ssl_certificate /etc/ssl/certs/localhost.crt;
                ssl_certificate_key /etc/ssl/private/localhost.key;
                ssl_session_cache shared:SSL-electrs:1m;
                ssl_session_timeout 4h;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
                ssl_prefer_server_ciphers on;
        }
}" | sudo tee -a /etc/nginx/nginx.conf

        elif [ ${isStream} -gt 1 ]; then

                echo " Too many \`stream\` commands in nginx.conf. Please edit manually: \`sudo nano /etc/nginx/nginx.conf\` and retry"
                exit 1
        fi
fi

echo "allow port 50002 on ufw"
sudo ufw allow 50002

sudo systemctl enable nginx
sudo systemctl restart nginx

echo ""
echo "To connect from outside of the local network make sure the port 50002 is forwarded on your router"
echo "Eclair mobile wallet: In the \`Network info\` set the \`Current Electrum server\` to \`$YOUR_DOMAIN:50002\`"
echo "Electrum wallet: start with the options \`electrum --oneserver --server $YOUR_DOMAIN:50002:s"
echo ""
