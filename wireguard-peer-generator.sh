#!/bin/bash
set -euo pipefail

# Dependency check: ipcalc-ng, wg, and qrencode must be installed.
for cmd in ipcalc-ng wg qrencode; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: Required command '$cmd' is not installed. Please install it." >&2
    exit 1
  fi
done

# Check that exactly 7 parameters are provided.
if [ "$#" -ne 7 ]; then
  echo "Usage: $0 <wg_interface> <wg_server_public_key> <peer_name> <peer_ip/CIDR> <peer_dns> <peer_comment> <peer_endpoint (address:port)>"
  exit 1
fi

WG_INTERFACE="$1"
WG_SERVER_PUBLIC_KEY="$2"
PEER_NAME="$3"
PEER_IP="$4"
PEER_DNS="$5"
PEER_COMMENT="$6"
PEER_ENDPOINT="$7"

if ! ipcalc-ng "$PEER_IP" >/dev/null 2>&1; then
  echo "Error: Invalid IP/CIDR provided: '$PEER_IP'" >&2
  exit 1
fi

if ! ipcalc-ng "$PEER_DNS" >/dev/null 2>&1; then
  echo "Error: Invalid DNS provided: '$PEER_DNS'" >&2
  exit 1
fi

# Parse the endpoint parameter (expected format: address:port)
IFS=":" read -r ENDPOINT_ADDRESS ENDPOINT_PORT <<< "$PEER_ENDPOINT"
if [ -z "$ENDPOINT_ADDRESS" ] || [ -z "$ENDPOINT_PORT" ]; then
  echo "Error: Invalid endpoint format. Expected format: address:port" >&2
  exit 1
fi

# Validate endpoint port is a number.
if ! [[ "$ENDPOINT_PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: Endpoint port is not valid: '$ENDPOINT_PORT'" >&2
  exit 1
fi

# Generate the peer's keys
PEER_PRIVATE_KEY=$(wg genkey)
PEER_PUBLIC_KEY=$(echo "$PEER_PRIVATE_KEY" | wg pubkey)

CONFIG_DIR="configs"
mkdir -p "$CONFIG_DIR"

RSC_FILE="${CONFIG_DIR}/${PEER_NAME}.rsc"
CONF_FILE="${CONFIG_DIR}/${PEER_NAME}.conf"
PNG_FILE="${CONFIG_DIR}/${PEER_NAME}.png"

cat > "$RSC_FILE" <<EOF
/interface/wireguard/peers/add \\
  interface="${WG_INTERFACE}" \\
  name="${PEER_NAME}" \\
  comment="${PEER_COMMENT}" \\
  public-key="${PEER_PUBLIC_KEY}" \\
  preshared-key="auto" \\
  allowed-address="${PEER_IP}" \\
  endpoint-address="${ENDPOINT_ADDRESS}" \\
  endpoint-port="${ENDPOINT_PORT}"
  persistent-keepalive=25 \\
  client-address="${PEER_IP}" \\
  client-dns="${PEER_DNS}" \\
  client-endpoint="${ENDPOINT_ADDRESS}" \\
  client-listen-port="${ENDPOINT_PORT}" \\
  client-keepalive=25 \\
EOF

# Write the WireGuard peer configuration file.
cat > "$CONF_FILE" <<EOF
[Interface]
PrivateKey = ${PEER_PRIVATE_KEY}
Address = ${PEER_IP}
DNS = ${PEER_DNS}

[Peer]
PublicKey = ${WG_SERVER_PUBLIC_KEY}
Endpoint = ${PEER_ENDPOINT}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Generate a QR coden.
qrencode -o "$PNG_FILE" -t PNG < "$CONF_FILE"

echo "Mikrotik command (.rsc file):"
echo "---------------------------------"
cat "$RSC_FILE"
echo "---------------------------------"
echo ""

echo "WireGuard configuration (.conf file):"
echo "---------------------------------"
cat "$CONF_FILE"
echo "---------------------------------"
echo ""

echo "QR Code generated in file: ${PNG_FILE}"
echo "Scan this QR code on the client:"
qrencode -t ANSIUTF8 < "$CONF_FILE"
