#!/bin/bash

read -p "Please enter your new hostname: " hostname
sudo hostnamectl set-hostname $hostname

# Download Iptables
echo
echo
echo "#################"
echo "Downloading and setting up port forwarding"
echo "#################"
echo

curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/iptable.txt
sudo apt-get install -y iptables-persistent 
curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/sysctl.conf



# Install cert
echo
echo
echo "#################"
echo "Downloading and installing cert"
echo "#################"
echo

curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/chosen.crt
cd /usr/share/ca-certificates
sudo cp /home/pi/chosen.crt amead_ca.crt
sudo dpkg-reconfigure ca-certificates

# Install Node-RED nodes.
echo
echo
echo "################"
echo "Installing Nodes"
echo "################"
echo

cd $nodered_dir
npm install node-red-contrib-opcua-server
npm install node-red-contrib-opcua-server-refresh
npm install node-red-contrib-opcua
npm install node-red-omronplc
npm install node-red-contrib-omron-fins
npm install node-red-show-value
npm install node-red-contrib-modbus
npm install @serafintech/node-red-contrib-eip-io
npm install node-red-contrib-schneider-powerlogic
npm install node-red-contrib-network-tools
npm install node-red-contrib-thingrest
npm install node-red-contrib-edge-trigger
npm install node-red-contrib-persistent-global-context


sudo mv sysctl.conf /etc/sysctl.conf
sudo mv iptables.txt /etc/iptables/rules.v4

read -p "Set ETH1 interface IP: " ETH1
sudo nmcli connection modify 'Wired connection 2'  ipv4.method manual   ipv4.addresses $ETH1

read -p "Set STEAME/STE-AME passkey: " passkey


nmcli connection add type wifi con-name STEAME ifname wlan0 ssid STEAME
nmcli connection modify STEAME wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "macd" 802-1x.password @passkey 802-1x.phase2-auth mschapv2 802-1x.system-ca-certs yes

nmcli connection add type wifi con-name STE-AME ifname wlan0 ssid STE-AME
nmcli connection modify STE-AME wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "macd" 802-1x.password @passkey 802-1x.phase2-auth mschapv2 802-1x.system-ca-certs yes



echo
echo
echo "#####################################"
echo "PDS Cytron MCA Setup Completed"
echo "#####################################"
echo
echo "Please reboot for the changes to take effect."
echo -n WLAN0 mac address: 
cat /sys/class/net/wlan0/address
echo -n ETH0 mac address: 
cat /sys/class/net/eth0/address
echo "It will take some times to reboot."