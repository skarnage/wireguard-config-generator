#!/bin/bash

# Name, comment, port
wg_interface=("wireguard" "" "48450")

# Wireguard interface, Wireguard public key, name, ip, dns, comment, endpoint:port
wg_peer0=("wireguard" "2TYAnfYAgDEQhcukVzQPOJmLJc6l5wl7JjJ+8wVpLUw=" "Lou" "192.168.216.10" "192.168.2.1" "" "107.159.60.200:48450")
wg_peer1=("wireguard" "2TYAnfYAgDEQhcukVzQPOJmLJc6l5wl7JjJ+8wVpLUw=" "Claudine" "192.168.216.11" "192.168.2.1" "" "107.159.60.200:48450")
wg_peer2=("wireguard" "2TYAnfYAgDEQhcukVzQPOJmLJc6l5wl7JjJ+8wVpLUw=" "Loxanh" "192.168.216.12" "192.168.2.1" "" "107.159.60.200:48450")
wg_peer3=("wireguard" "2TYAnfYAgDEQhcukVzQPOJmLJc6l5wl7JjJ+8wVpLUw=" "Ezekiel" "192.168.216.13" "192.168.2.1" "" "107.159.60.200:48450")

# WG Network, WG port, LAN network
firewall=("192.168.216.0/24" "48450" "192.168.2.0/24")

./wireguard-interface-generator.sh "${wg_interface[@]}"

./wireguard-peer-generator.sh "${wg_peer0[@]}"
./wireguard-peer-generator.sh "${wg_peer1[@]}"
./wireguard-peer-generator.sh "${wg_peer2[@]}"
./wireguard-peer-generator.sh "${wg_peer3[@]}"

./wireguard-firewall-generator.sh "${firewall[@]}"