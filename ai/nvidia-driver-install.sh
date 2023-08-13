sudo apt-get install -y linux-headers-$(uname -r)
# for TCMalloc (improves CPU memory usage)
sudo apt install -y libgoogle-perftools-dev


wget https://us.download.nvidia.com/XFree86/Linux-x86_64/535.86.05/NVIDIA-Linux-x86_64-535.86.05.run

chmod +x NVIDIA-Linux-x86_64-535.86.05.run

sudo ./NVIDIA-Linux-x86_64-535.86.05.run

# disable nuveau drivers
# needs reboot

# ? install pkg-config