#!/bin/bash
export MIX_TARGET=mqscope
export MIX_ENV=dev
cd ../zoizoui
mix deps.get
mix assets.deploy
cd ../zoizo
#mix clean
mix deps.get
mix firmware
export NERVES_WIFI_SSID='Tomato'
export CPATH="${CPATH}:/usr/include/x86_64-linux-gnu/"
export NERVES_WIFI_PASSPHRASE='mozarella_rucola_3000'
mix burn
sync
ssh-keygen -R nerves.local