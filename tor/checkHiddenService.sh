#!/bin/bash

hidden_service="xxxxxxxxxx.onion"
port=80
if ! torsocks nc -zv ${hidden_service} ${port}; then
  echo "restart Tor"
  sudo systemctl restart tor@default
fi
