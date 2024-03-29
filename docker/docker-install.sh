# Installs docker
sudo apt update -y
sudo apt install docker.io -y
docker --version

# Installs docker-compose. [ref](https://docs.docker.com/compose/install/)
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version