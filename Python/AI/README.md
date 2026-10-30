# SETUP

## init

```bash

export FOUNDRY_PROJECT_ENDPOINT=$(az cognitiveservices account project show --name integration-it --resource-group rg-ai-integration-it --project-name integration-it-project -o json | jq '.properties.endpoints."AI Foundry API"' -r)


source /home/lacour/code/python/devenv/bin/activate


pip install azure-identity --upgrade
pip install azure-ai-projects --upgrade
pip install openai --upgrade





```