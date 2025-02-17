#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <interface_name> <comment> <listen_port>"
    exit 1
fi

IF_NAME="$1"
COMMENT="$2"
LISTEN_PORT="$3"

if ! command -v wg &>/dev/null; then
    echo "Error: 'wg' tool is not installed. Please install wireguard-tools."
    exit 1
fi

# Validate the interface name: allow only letters, numbers, underscores, and hyphens.
if [[ ! "$IF_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Invalid interface name. Only letters, numbers, underscores, and hyphens are allowed."
    exit 1
fi

# Validate the listen port: it must be a number between 1 and 65535.
if ! [[ "$LISTEN_PORT" =~ ^[0-9]+$ ]] || [ "$LISTEN_PORT" -lt 1 ] || [ "$LISTEN_PORT" -gt 65535 ]; then
    echo "Error: Invalid listen port. It must be a number between 1 and 65535."
    exit 1
fi

# Generate keys
PRIVATE_KEY=$(wg genkey)
if [ $? -ne 0 ] || [ -z "$PRIVATE_KEY" ]; then
    echo "Error: Failed to generate the private key."
    exit 1
fi

PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)
if [ $? -ne 0 ] || [ -z "$PUBLIC_KEY" ]; then
    echo "Error: Failed to generate the public key."
    exit 1
fi

CONFIG_DIR="configs"
mkdir -p "$CONFIG_DIR"
OUTPUT_FILE="${CONFIG_DIR}/${IF_NAME}.rsc"

cat > "$OUTPUT_FILE" <<EOF
/interface wireguard add name=${IF_NAME} listen-port=${LISTEN_PORT} private-key="${PRIVATE_KEY}" comment="${COMMENT}"
# Public Key: ${PUBLIC_KEY}
EOF

echo "Mikrotik WireGuard interface configuration written to ${OUTPUT_FILE}"
