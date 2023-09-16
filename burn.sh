export MIX_TARGET=mqscope
mix firmware
mix burn
sync
ssh-keygen -R nerves.local
 
