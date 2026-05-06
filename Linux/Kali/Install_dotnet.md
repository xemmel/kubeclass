## Install dotnet via script

### Install

```bash

wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

```

### Check latest version

```bash

LATEST=$(curl -s https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/10.0/releases.json \
  | grep '"latest-sdk"' | head -1 | cut -d '"' -f4)

CURRENT=$(dotnet --version)

if [ "$LATEST" != "$CURRENT" ]; then
    echo "New .NET 10 SDK available: $LATEST (you have $CURRENT)"
else
    echo ".NET SDK is current: $CURRENT"
fi


```

### Upgrade

```bash

./dotnet-install.sh --channel 10.0

```