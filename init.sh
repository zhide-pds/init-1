#!/bin/bash

read -p "Please enter your new hostname: " hostname
sudo hostname $hostname


# Download Iptables
echo
echo
echo "#################"
echo "Downloading and setting up port forwarding"
echo "#################"
echo

curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/iptable.txt
sudo apt-get install iptables-persistent
sudo mv iptables.txt /etc/iptables/rules.v4
curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/sysctl.conf
sudo mv sysctl.conf /etc/sysctl.conf


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




echo
echo
echo "#####################################"
echo "PDS Cytron MCA Setup Completed"
echo "#####################################"
echo
echo "Please reboot for the changes to take effect."
echo -n WLAN0 mac address: 
cat /sys/class/net/wlan0/address
echo "It will take some times to reboot."