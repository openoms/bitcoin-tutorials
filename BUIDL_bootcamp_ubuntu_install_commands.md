sudo apt-get update
sudo apt-get upgrade

sudo apt install git-all

git clone https://github.com/superquest/digital-cash.git
cd digital-cash

apt-get install python3-venv

python3 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt

# jupyter notebook

# install docker as described here: https://docs.docker.com/install/linux/docker-ce/ubuntu/

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# verify fingerprint `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce

# to test docker install: 
# sudo docker run hello-world

sudo systemctl enable docker

# to check if Docker is running:
# systemctl status docker.service

sudo groupadd docker
sudo usermod -aG docker $USER

# install docker compose as in here https://docs.docker.com/compose/install/

sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# to test the docker-compose installation:
# docker-compose --version

# RESTART:
# sudo shutdown now -r

cd digital-cash/
																																																																																																																																															source venv/bin/activate
cd experiments/
docker-compose up --build

# more troubleshooting: https://docs.docker.com/install/linux/linux-postinstall/
