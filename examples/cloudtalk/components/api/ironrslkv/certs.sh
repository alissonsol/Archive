#!/bin/bash
# Docs: https://github.com/microsoft/Ironclad/tree/main/ironfleet
#   dotnet bin/CreateIronServiceCerts.dll outputdir=certs name=MyKV type=IronRSLKV addr1=127.0.0.1 port1=4001 addr2=127.0.0.1 port2=4002 addr3=127.0.0.1 port3=4003
#   becomes
#   dotnet bin/CreateIronServiceCerts.dll outputdir=certs name=MyKV type=IronRSLKV ${env:ironCerts}

echo "-- certs started --"

# Install tools
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
touch /etc/apt/sources.list.d/kubernetes.list 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl
sleep 9

# Configuration
binariesDir="/workspace/Ironclad/ironfleet/bin/"
echo "certsName: ${certsName}"
echo "certsType: ${certsType}"
echo "certsDir: ${certsDir}"
echo "ironCerts: ${ironCerts}"

# CreateIronServiceCerts
dotnet ${binariesDir}/CreateIronServiceCerts.dll outputdir=${certsDir} name=${certsName} type=${certsType} ${ironCerts}

while true; do echo 'Hit CTRL+C'; sleep 60; done
echo "-- certs ended --"
