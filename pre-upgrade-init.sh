#!/bin/bash
set -e # Abort the script at first error
set -u # Treat unset variables as an error

# -----------------------
# Variables
# -----------------------

# File and directory paths
KEYS_DIR=~/keys
MINA_ENV_FILE=~/.mina-env
MINA_SERVICE_FILE=/etc/systemd/system/mina.service

# APT Repository details
REPO_URL="http://packages.o1test.net"
REPO_DISTRO="$(lsb_release -cs)"
REPO_COMPONENT="umt"
MINA_PACKAGE="mina-devnet=1.0.0umt-2025a73"

# -----------------------
# Functions
# -----------------------

# Ensure a variable is set and not empty
ensure_var() {
    local var_name="$1"
    local prompt_msg="$2"

    while true; do
        read -p "$prompt_msg" input
        if [[ -z "$input" ]]; then
            echo "Input cannot be empty."
        else
            eval "$var_name='$input'"
            break
        fi
    done
}

# -----------------------
# Main Script
# -----------------------

# Remove old APT sources and add the new source
sudo rm -f /etc/apt/sources.list.d/mina*.list
echo "deb [trusted=yes] $REPO_URL $REPO_DISTRO $REPO_COMPONENT" | sudo tee /etc/apt/sources.list.d/mina.list

# Update APT and install the specified version of Mina
sudo apt-get update
sudo apt-get install --allow-downgrades -y "$MINA_PACKAGE"

# Create and set permissions for keys directory
mkdir -p "$KEYS_DIR"
chmod 700 "$KEYS_DIR"

# Read and verify user inputs
ensure_var json_string "Enter the key json string: "
ensure_var public_key "Enter public key: "
ensure_var external_ip "Enter external IP: "
ensure_var MINA_PRIVKEY_PASS "Enter MINA_PRIVKEY_PASS: "

# Write keys and permissions
echo "$json_string" > "$KEYS_DIR/my-wallet"
echo "$public_key" > "$KEYS_DIR/my-wallet.pub"
chmod 600 "$KEYS_DIR/my-wallet" "$KEYS_DIR/my-wallet.pub"

# Generate Mina keypair
mina advanced generate-libp2p-keypair -privkey-path "$KEYS_DIR/keys"

# Generate Mina environment file
cat <<EOL > "$MINA_ENV_FILE"
MINA_PRIVKEY_PASS="$MINA_PRIVKEY_PASS"
UPTIME_PRIVKEY_PASS="$MINA_PRIVKEY_PASS"
MINA_LIBP2P_PASS="$MINA_PRIVKEY_PASS"
EXTRA_FLAGS="--config-directory /root/.mina-config/ --enable-peer-exchange true --external-ip $external_ip --file-log-level Debug --generate-genesis-proof true --insecure-rest-server --discovery-keypair /root/keys/keys --log-json --log-level Debug --log-precomputed-blocks true --log-snark-work-gossip true --node-error-url https://nodestats-itn.minaprotocol.tools/submit/stats --node-status-url https://nodestats-itn.minaprotocol.tools/submit/stats --peer-list-url https://storage.googleapis.com/o1labs-gitops-infrastructure/o1labs-umt-pre-fork-run-1/seed-list-o1labs-umt-pre-fork-run-1.txt --block-producer-key /root/keys/my-wallet"
RAYON_NUM_THREADS=6
EOL

chmod 600 "$MINA_ENV_FILE"

# Generate and start the Mina systemd service
cat <<EOL | sudo tee "$MINA_SERVICE_FILE"
[Unit]
Description=Mina Daemon Service
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
Environment="PEERS_LIST_URL=https://storage.googleapis.com/o1labs-gitops-infrastructure/o1labs-umt-pre-fork-run-1/seed-list-o1labs-umt-pre-fork-run-1.txt"
Environment="LOG_LEVEL=Info"
Environment="FILE_LOG_LEVEL=Debug"
EnvironmentFile=$MINA_ENV_FILE
Type=simple
Restart=always
RestartSec=30
ExecStart=/usr/local/bin/mina daemon \$EXTRA_FLAGS
ExecStop=/usr/local/bin/mina client stop-daemon

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, restart Mina service, enable it to start at boot
sudo systemctl daemon-reload
sudo systemctl restart mina
sudo systemctl enable mina

# Show recent logs and follow new logs
journalctl -u mina -n 1000 -f
