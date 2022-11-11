#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
if [ "$(uname -m)" != "x86_64" ]
  then echo "Your system type needs to be x86_64"
  exit
fi
if [ "$(awk -F= '/^NAME/{print $2}' /etc/os-release)" != '"Ubuntu"' ]
  then echo "Only ubuntu is supported distro"
  exit
fi
export DEBIAN_FRONTEND=noninteractive
if [ -x "$(command -v docker)" ]; then
    apt update -y && apt upgrade -y
else
    apt update -y
    apt install ca-certificates curl gnupg lsb-release tar -y
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    apt update -y
    apt install install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
fi
if [ -x "$(command -v docker)" ]; then
  docker network create   --driver=bridge   --subnet=172.18.0.0/16   --ip-range=172.18.0.0/16   --gateway=172.18.0.1   clore-br0 &>/dev/null
  docker pull cloreai/ubuntu20.04-jupyter
  docker pull cloreai/clore-wireguard
else
  echo "docker instalation failure" && exit
fi
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt update
apt install -y nvidia-docker2
mkdir /opt/clore-hosting/ &>/dev/null
mkdir /opt/clore-hosting/startup_scripts &>/dev/null
mkdir /opt/clore-hosting/wireguard &>/dev/null
mkdir /opt/clore-hosting/wireguard/configs &>/dev/null
mkdir /opt/clore-hosting/client &>/dev/null
tar -xvf clore-hosting.tar -C /opt/clore-hosting/client &>/dev/null
tar -xvf node-v16.18.1-linux-x64.tar.xz -C /opt/clore-hosting &>/dev/null
rm /opt/clore-hosting/service.sh &>/dev/null
rm /opt/clore-hosting/clore.sh &>/dev/null
tee -a /opt/clore-hosting/service.sh > /dev/null <<EOT
#!/bin/bash
CLIENT_DIR=/opt/clore-hosting/client
NODE=/opt/clore-hosting/node-v16.18.1-linux-x64/bin/node
cd \$CLIENT_DIR
while true
do
if test -f "\$CLIENT_DIR/auth"; then
    \$NODE index.js -main true
fi
sleep 1
done
EOT
tee -a /opt/clore-hosting/clore.sh > /dev/null <<EOT
#!/bin/bash
cd /opt/clore-hosting/client
/opt/clore-hosting/node-v16.18.1-linux-x64/bin/node index.js "\$@"
EOT
tee -a /etc/systemd/system/clore-hosting.service > /dev/null <<EOT
[Unit]
Description=CLORE.AI Hosting service

[Service]
User=root
ExecStart=/opt/clore-hosting/service.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOT
chmod +x /opt/clore-hosting/service.sh
chmod +x /opt/clore-hosting/clore.sh
systemctl enable clore-hosting.service
echo "------INSTALATION COMPLETE------"
echo "For connection to clore ai use /opt/clore-hosting/clore.sh --init-token <token>"
echo "and then reboot"