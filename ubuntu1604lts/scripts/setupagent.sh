# Variables
VSTSURL="https://domain.visualstudio.com"
PAT=""
AGENTPOOL=""

# Install JQ
sudo apt-get -y install jq

### Azure CLI 2.0 ###

# Modify your sources list
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

# Get the Microsoft signing key
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Install Azure CLI 2.0 with apt
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli

### VSTS Agent ###

# Download and extract the agent
mkdir agent && cd agent
curl -L https://vstsagentpackage.azureedge.net/agent/2.136.1/vsts-agent-linux-x64-2.136.1.tar.gz | tar zx

# Install .Net core 2.0 dependencies from agent folder
sudo ./bin/installdependencies.sh

# Configure the VSTS agent
./config.sh \
    --unattended \
    --url $VSTSURL \
    --auth pat \
    --token $PAT \
    --pool $AGENTPOOL \
    --agent $HOSTNAME \
    --replace \
    --acceptTeeEula

# Configure the agent to start as a service ank start after reboot
sudo ./svc.sh install
sudo ./svc.sh start