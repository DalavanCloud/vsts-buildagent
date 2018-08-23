#!/bin/bash

# Parameters : Validate that all arguments are supplied
if [ $# -lt 3 ]; then unsuccessful_exit "Insufficient parameters supplied." 1; fi

# Variables
VSTSURL=$1
PAT=$2
AGENTPOOL=$3

echo "--- Install JQ ---"
#sudo 
apt-get -y install jq

echo "### Azure CLI 2.0 ###"

echo "--- Modify your sources list ---"
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list #sudo 

echo "--- Get the Microsoft signing key ---"
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

echo "--- Install Azure CLI 2.0 with apt ---"
# sudo 
apt-get install apt-transport-https
# sudo 
apt-get update && sudo apt-get install azure-cli

echo "### VSTS Agent ###"

echo "--- Download and extract the VSTS agent --"
#sudo 
#create a new group
groupadd agents
#add the user to the group
usermod -aG agents buildagent
#verify what users are part of the group
grep agents /etc/group
#create a directory
mkdir /agent
#set ownership of the folder to the group
chgrp agents /agent
# set read/write permissions for the new group
chmod -R 0760 /agent

sudo -u buildagent curl -L https://vstsagentpackage.azureedge.net/agent/2.136.1/vsts-agent-linux-x64-2.136.1.tar.gz | tar zx -C /agent

echo "--- Install .Net core 2.0 dependencies from agent folder ---"
#sudo 
./bin/installdependencies.sh

cd /agent
echo "--- Configure the VSTS agent ---"
./config.sh \
    --unattended \
    --url $VSTSURL \
    --auth pat \
    --token $PAT \
    --pool $AGENTPOOL \
    --agent $HOSTNAME \
    --replace \
    --acceptTeeEula

echo "--- Configure the agent to start as a service ank start after reboot ---"
#sudo 
./svc.sh install
#sudo 
./svc.sh start

# echo "Commands succeeded. Exiting";
# exit 0;