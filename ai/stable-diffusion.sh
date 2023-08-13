Got a fresh instance of the https://github.com/AUTOMATIC1111/stable-diffusion-webui for logo design experiments at: https://stablediffusion.diynodes.com/
To generate .svg files - choose the script `Vector Studio` on the bottom.
more info at: https://github.com/GeorgLegato/stable-diffusion-webui-vectorstudio
Promting it is a bit of an art, but go ahead and play until my disk is full or the server crashes.

sudo adduser --disabled-password --gecos "" sd
sudo su - sd

cd download
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
cd stable-diffusion-webui
./webui.sh

https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Xformers#building-xformers-on-linux-from-anonymous-user

# REVERSE PROXY
sudo nano /etc/nginx/conf.d/stablediffusionwebui.conf

server {
    listen 0.0.0.0:7861;

    location / {
        proxy_pass http://127.0.0.1:7860;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

sudo nginx -t && sudo systemctl restart nginx

# SYSTEMD SERVICE
sudo systemctl edit --full --force stablediffusionwebui.service
[Unit]
Description=Web UI script

[Service]
Type=simple
User=sd
Group=sd
WorkingDirectory=/home/sd/stable-diffusion-webui
ExecStart=/bin/bash /home/sd/stable-diffusion-webui/webui.sh
Restart=always
StandardOutput=journal
StandardError=journal
TimeoutSec=60
Restart=always
RestartSec=60

# Hardening measures
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
# PrivateDevices=true - breaks CUDA check

[Install]
WantedBy=multi-user.target

sudo systemctl enable --now stablediffusionwebui.service

sudo systemctl restart stablediffusionwebui.service


https://github.com/GeorgLegato/stable-diffusion-webui-vectorstudio
sudo apt install potrace
ln -s /usr/bin/potrace extensions/stable-diffusion-webui-vectorstudio/bin/potrace

nano webui-user.sh
export COMMANDLINE_ARGS="--xformers --share"


tmux a
~/download/stable-diffusion-webui/webui.sh