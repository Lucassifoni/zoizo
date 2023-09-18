#!/bin/bash
export MIX_TARGET=mqscope
mix clean
mix firmware
export NERVES_WIFI_SSID='Tomato'
export NERVES_WIFI_PASSPHRASE='mozarella_rucola_3000'
mix burn
sync
ssh-keygen -R nerves.local