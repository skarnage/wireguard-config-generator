# 🖧 WireGuard Configuration Generator

Basic idea and inspiration is from https://github.com/bitcanon/wireguard-tunnel-generator

## Introduction
A simple bash script to speed up and simplify the deployment of WireGuard connecting to a MikroTik router running RouterOS.

The script will produce the RouterOS configuration required as well as a QR code to scan with the WireGuard app.

This will enable you to deploy a new VPN client within a minute or two, and you don't have to send public keys back and forth between the device and the router.

With the added parameters, it is now possible to generate the clients configurations (QR included) directly on the MikroTik device!

## Installation
Download the script from GitHub (or git clone) and place it inside your home directory.

The script needs three packages in order to operate correctly:
```
sudo apt install ipcalc-ng wireguard-tools qrencode
```
1. `ipcalc-ng` is used to validate IP adress input.
2. `wireguard-tools` is used to generate private/public key pair.
3. `qrencode` is used to encode the WireGuard configuration into a QR code.

## Basics
### Parameters

Everything is self documented.

Example in `wireguard-generator.sh`

## 🖧 WireGuard Interface Configuration
One thing to keep in mind when running the script is whether a **WireGuard Interface** has been configured on the router or not.

This is important because we only need one interface for the WireGuard endpoint on the router (assuming that all VPN clients are put on the same subnet). 

If the interface is created from RouterOS, the private/public key pair is generated automatically. If not, just let the script create the configuration for you.
 
### WireGuard Interface is configured

When the interface is pre-configured you need to get the **public key** from the configuration in RouterOS.

>Here we assume that the name of the WireGuard interface is `wg`.

**WinBox**:
- Go to WireGuard, open the `wg` interface in the WireGuard tab and *copy the public key*.

**Terminal**:
- Run the command `:put ([/interface/wireguard/get wg ]->"public-key")` and *copy the public key*.


### WireGuard Interface need to be configured

When the interface doesn't exist you can have the script generate the configuration for you..

- Pass the **public key** as an argument to the script.

>The private and public keys of the firewall is only created once and then used by all clients.

### WireGuard Configuration
The WireGuard configuration to be imported into the WireGuard client is exported into a configuration (`peer_name.conf`) file with the name as the filename.

### QR Code
The configuration in the **WireGuard Configuration** section above will also be encoded into a QR code using the `qrencode` utility.

This QR code will:
1. Be printed as text in the **terminal** for instant use.
2. Saved into a **PNG image** file `./configs/peer_name.png`. 

### RouterOS Configuration
The RouterOS configuration needed in order to get the tunnel up and running will also be available for you.

The configuration will:
1. Be printed as text in the **terminal** for instant use; just copy and paste into RouterOS.
2. Saved into a **RouterOS Script** file `./configs/peer_name.rsc`. 

## Further Reading
For more information on how to setup a WireGuard Tunnel between a mobile device and MikroTik RouterOS:
* https://help.mikrotik.com/docs/display/ROS/WireGuard#WireGuard-RoadWarriorWireGuardtunnel
