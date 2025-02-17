#!/bin/bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <wireguard_network> <wireguard_port> <lan_network>"
    echo "Example: $0 \"10.0.0.0/24\" 51820 \"192.168.1.0/24\""
    exit 1
fi

WG_NETWORK="$1"
WG_PORT="$2"
LAN_NETWORK="$3"

if ! [[ "$WG_PORT" =~ ^[0-9]+$ ]]; then
    echo "Error: WireGuard port must be numeric."
    exit 1
fi

CONFIG_DIR="configs"
mkdir -p "$CONFIG_DIR"
FW_FILE="${CONFIG_DIR}/firewall.rsc"

# Create the fw.rsc file with the necessary Mikrotik commands.
# (Adjust the 'gateway' in the route command if needed.)
cat > "$FW_FILE" <<EOF
# === WireGuard Server Configuration ===

# 1. Route: Ensure the router knows about the WireGuard network.
# (If your WireGuard interface is already assigned this network, this route might be auto-generated.)
/ip route add dst-address=$WG_NETWORK gateway=wireguard comment="Route to WireGuard network"

# 2. NAT: Masquerade traffic from WireGuard clients going out to the Internet.
# (Remove or adjust 'out-interface' if you have a specific WAN interface configured.)
/ip firewall nat add chain=srcnat src-address=$WG_NETWORK action=masquerade comment="NAT for WireGuard clients"

# 3. Firewall Filter: Allow incoming WireGuard UDP connections.
# (This rule allows WireGuard handshake traffic to reach the router.)
/ip firewall filter add chain=input protocol=udp dst-port=$WG_PORT action=accept comment="Allow WireGuard UDP connections"

# 4. Firewall Filter: Allow established and related connections.
# (Ensure returning traffic is accepted.)
/ip firewall filter add chain=input connection-state=established,related action=accept comment="Allow established/related connections"

# 5. Forwarding Rules: Allow WireGuard clients to access the LAN.
# Allow traffic from WireGuard network to LAN.
 /ip firewall filter add chain=forward src-address=$WG_NETWORK dst-address=$LAN_NETWORK action=accept comment="Allow WG clients to LAN"
# Allow responses from LAN to WireGuard clients.
 /ip firewall filter add chain=forward src-address=$LAN_NETWORK dst-address=$WG_NETWORK action=accept comment="Allow LAN to WG clients"

# 6. Forwarding Rules: Allow WireGuard clients to access the Internet.
# Allow all traffic from WG clients (adjust if you need tighter control).
/ip firewall filter add chain=forward src-address=$WG_NETWORK action=accept comment="Allow WG clients to Internet"
# Allow incoming traffic to WG clients (if necessary).
/ip firewall filter add chain=forward dst-address=$WG_NETWORK action=accept comment="Allow Internet to WG clients"

# === End of Configuration ===
EOF

echo "Mikrotik configuration has been generated in the file: ${FW_FILE}"
