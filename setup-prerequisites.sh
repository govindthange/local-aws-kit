#!/bin/bash
set -e

echo "🔍 Detecting Host Operating System..."
OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH_TYPE="$(uname -m)"

# Normalize architecture strings for download URLs
if [ "$ARCH_TYPE" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH_TYPE" = "aarch64" ] || [ "$ARCH_TYPE" = "arm64" ]; then
    ARCH="arm64"
else
    echo "❌ Unsupported architecture: $ARCH_TYPE"
    exit 1
fi

echo "💻 System Identified: $OS_TYPE ($ARCH)"

# =========================================================================
# MACOS INSTALLATION ROUTE (Using Homebrew)
# =========================================================================
if [ "$OS_TYPE" = "darwin" ]; then
    echo "📦 Checking for Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew is not installed. Please install it first from https://brew.sh or install Docker Desktop manually."
        exit 1
    fi

    echo "⚙️ Installing KinD and Kubectl via Homebrew..."
    brew install kind kubectl
    
    echo "🐳 Note: Please ensure Docker Desktop for Mac is downloaded and running."

# =========================================================================
# LINUX INSTALLATION ROUTE (Native Binary Downloads)
# =========================================================================
elif [ "$OS_TYPE" = "linux" ]; then
    echo "⚙️ Downloading and installing KinD binary..."
    curl -Lo ./kind "https://k8s.io{ARCH}"
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind

    echo "⚙️ Downloading and installing kubectl binary..."
    curl -Lo ./kubectl "https://k8s.io(curl -L -s https://k8s.io)/bin/linux/${ARCH}/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

    echo "🐳 Note: Ensure Docker Engine is installed and your user is part of the 'docker' group."
else
    echo "❌ This automation script only supports macOS and Linux. For Windows, please use 'choco install kind kubernetes-cli'."
    exit 1
fi

# =========================================================================
# VALIDATION RESOURCING
# =========================================================================
echo "🚀 Validating Tool Installations..."
echo "✅ KinD Version: $(kind version)"
echo "✅ Kubectl Version: $(kubectl version --client --output=yaml | grep gitVersion)"
echo "🎉 Prerequisites successfully configured! You can now execute ./setup.sh safely."
