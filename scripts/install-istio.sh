#!/bin/bash

set -e

echo "Installing Istio on docker-desktop cluster..."

# Check if istioctl is installed
if ! command -v istioctl &> /dev/null; then
    echo "istioctl not found. Installing Istio CLI..."

    # Get latest Istio version
    ISTIO_VERSION=$(curl -s https://api.github.com/repos/istio/istio/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    echo "Latest Istio version: $ISTIO_VERSION"

    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    # Map architecture names
    if [ "$ARCH" = "x86_64" ]; then
        ARCH="amd64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        ARCH="arm64"
    fi

    # Download Istio
    echo "Downloading Istio ${ISTIO_VERSION} for ${OS}-${ARCH}..."
    ISTIO_DIR="istio-${ISTIO_VERSION}"
    DOWNLOAD_URL="https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-${OS}-${ARCH}.tar.gz"

    curl -L "$DOWNLOAD_URL" -o istio.tar.gz
    tar -xzf istio.tar.gz
    rm istio.tar.gz

    if [ ! -d "$ISTIO_DIR" ]; then
        echo "Error: Failed to extract Istio"
        exit 1
    fi

    export PATH="$PWD/$ISTIO_DIR/bin:$PATH"
    echo ""
    echo "Istio CLI installed to $PWD/$ISTIO_DIR/bin"
    echo "You may want to add this to your PATH:"
    echo "  export PATH=\"$PWD/$ISTIO_DIR/bin:\$PATH\""
    echo ""
fi

# Check current context
CURRENT_CONTEXT=$(kubectl config current-context)
echo "Current kubectl context: $CURRENT_CONTEXT"

if [ "$CURRENT_CONTEXT" != "docker-desktop" ]; then
    echo "Warning: Current context is not docker-desktop. Continue? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        echo "Aborting."
        exit 1
    fi
fi

# Install Istio with demo profile
echo "Installing Istio with demo profile..."
istioctl install --set profile=demo -y

# Wait for Istio to be ready
echo "Waiting for Istio components to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment -l app=istiod -n istio-system

echo "Istio installation complete!"
echo ""
echo "Verify installation:"
echo "  kubectl get pods -n istio-system"
echo ""
echo "Next steps:"
echo "  ./scripts/deploy.sh"
