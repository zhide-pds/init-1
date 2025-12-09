#!/bin/bash

curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/default.json
curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/iptable.txt
curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/sysctl.conf
curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/chosen.crt
curl -LO https://raw.githubusercontent.com/zhide-pds/init-1/refs/heads/main/settings.js


# SET WIFI Country
echo
echo
echo "#################"
echo "SET Hostname and Wifi Country to SG"
echo "#################"
echo

read -p "Please enter your new hostname: " hn

sudo cp /etc/hosts /etc/hosts.bak
OLD_HOSTNAME=$(hostname)

#sudo hostnamectl set-hostname $hostname
sudo raspi-config nonint do_hostname $hn

COUNTRY_CODE="SG"
WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"

sudo raspi-config nonint do_wifi_country "$COUNTRY_CODE"

sudo cp "$WPA_CONF" "$WPA_CONF.bak"
if sudo grep -q '^country=' "$WPA_CONF"; then
    sudo sed -i "s/^country=.*/country=$COUNTRY_CODE/" "$WPA_CONF"
else
    sudo sed -i "1icountry=$COUNTRY_CODE" "$WPA_CONF"
fi
sudo iw reg set "$COUNTRY_CODE"
sudo wpa_cli -i wlan0 reconfigure
echo "Country set to $COUNTRY_CODE"
iw reg get


# Enable VNC
echo
echo
echo "#################"
echo "Enabling VNC"
echo "#################"
echo
sudo ln -s /usr/lib/systemd/system/vncserver-x11-serviced.service /etc/systemd/system/multi-user.target.wants/vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced


# Download Iptables
echo
echo
echo "#################"
echo "Downloading and setting up port forwarding"
echo "#################"
echo


sudo apt-get install -y iptables-persistent 


# Install cert
echo
echo
echo "#################"
echo "Downloading and installing cert"
echo "#################"
echo

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


cd /home/pi/.node-red

npm install node-red-contrib-opcua-server
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
npm install node-red-contrib-siemens-sentron
npm install node-red-contrib-s7

sudo mv /home/pi/settings.js settings.js
sudo mv /home/pi/default.json flows.json 



#sudo mv ~/sysctl.conf /etc/sysctl.conf
#sudo mv ~/iptable.txt /etc/iptables/rules.v4

sudo nmcli con add type wifi con-name "office" ifname wlan0 ssid "pdsol-2-2.4GHz" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "11223344556677889900aabbcc"
sudo nmcli con add type wifi con-name "test" ifname wlan0 ssid "loh&low" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "1q2w3e4r"


read -p "Set ETH1 interface IP: " ETH1
sudo nmcli connection modify 'Wired connection 2'  ipv4.method manual   ipv4.addresses $ETH1'/24'

read -p "Set STEAME/STE-AME passkey: " PASSKEY

sudo nmcli connection add type wifi con-name STEAME ifname wlan0 ssid STEAME
sudo nmcli connection modify STEAME wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "macd" 802-1x.password $PASSKEY 802-1x.phase2-auth mschapv2 802-1x.system-ca-certs yes

sudo nmcli connection add type wifi con-name STE-AME ifname wlan0 ssid STE-AME
sudo nmcli connection modify STE-AME wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "macd" 802-1x.password $PASSKEY 802-1x.phase2-auth mschapv2 802-1x.system-ca-certs yes




echo
echo
echo "#####################################"
echo "PDS Cytron MCA Setup Completed"
echo "#####################################"
echo
echo
echo
echo WLAN0 mac address: 
cat /sys/class/net/wlan0/address
echo ETH0 mac address: 
cat /sys/class/net/eth0/address
echo "Please reboot for the changes to take effect."
echo "It will take some times to reboot."
