#!/bin/bash

#read -p 'Organization: ' ORG
#read -p 'Bucket: ' BUCKET
read -p 'Token: ' TOKEN
read -p 'Company: ' COMPANY
read -p 'Site: ' SITE

#dpkg -s 3cxpbx &> /dev/null

#if [ $? -eq 0 ]; then
#    template='{"Hostname":"%s","Username":"%s","Password":"%s"}'
#read -p 'Hostname: ' hostname
#read -p 'Password: ' password
#json_string=$(printf "$template" "$hostname" "admin" "$password")
#mkdir /etc/3cx_exporter
#echo "$json_string" > /etc/3cx_exporter/config.json

#wget atgfw.com/tig/3cx_exporter -O /usr/bin/3cx_exporter
#chmod +x /usr/bin/3cx_exporter
#wget atgfw.com/tig/3cx_exporter.service -O /etc/systemd/system/3cx_exporter.service

#systemctl enable 3cx_exporter
#systemctl start 3cx_exporter

#fi

# Before adding Influx repository, run this so that apt will be able to read the repository.

rm /etc/apt/sources.list.d/3cxpbx-testing.list
apt-get update && apt-get install apt-transport-https

# Add the InfluxData key

wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -  
source /etc/os-release  
test $VERSION_ID = "7" && echo "deb https://repos.influxdata.com/debian wheezy stable" | tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "8" && echo "deb https://repos.influxdata.com/debian jessie stable" | tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "9" && echo "deb https://repos.influxdata.com/debian stretch stable" | tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "10" && echo "deb https://repos.influxdata.com/debian buster stable" | tee /etc/apt/sources.list.d/influxdb.list

apt-get update && apt-get install telegraf

rm /etc/default/telegraf
touch /etc/default/telegraf
template='%s="%s"'
echo $(printf "$template" "INFLUX_ORG" "ATG") >> /etc/default/telegraf
echo $(printf "$template" "INFLUX_BUCKET" "ATG") >> /etc/default/telegraf
echo $(printf "$template" "INFLUX_TOKEN" "$TOKEN") >> /etc/default/telegraf
echo $(printf "$template" "COMPANY" "$COMPANY") >> /etc/default/telegraf
if [ -z "$SITE" ]; then
echo $(printf "$template" "SITE" "Main") >> /etc/default/telegraf
else
echo $(printf "$template" "SITE" "$SITE") >> /etc/default/telegraf
fi

wget atgfw.com/tig/sbctelegraf -O /etc/telegraf/telegraf.conf
wget atgfw.com/tig/telegraf.service -O /etc/systemd/system//multi-user.target.wants/telegraf.service

systemctl daemon-reload
systemctl restart telegraf