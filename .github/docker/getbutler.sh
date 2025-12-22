#!/bin/bash
set -e

BUTLER_VERSION="15.21.0"
BUTLER_URL="https://broth.itch.ovh/butler/linux-amd64/${BUTLER_VERSION}/archive/default"

mkdir -p /opt/butler/bin
cd /opt/butler
wget -q -O butler.zip "${BUTLER_URL}"
unzip -q butler.zip
chmod +x butler
mv butler /opt/butler/bin/butler
rm -f butler.zip

