#!/bin/bash

set -e

echo "Deploying Istio mesh test components..."

# Check if Istio is installed
if ! kubectl get namespace istio-system &> /dev/null; then
    echo "Error: Istio is not installed. Run ./scripts/install-istio.sh first"
    exit 1
fi

# Create namespace with Istio injection
echo "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Deploy mitmproxy
echo "Deploying mitmproxy..."
kubectl apply -f k8s/mitmproxy/

# Deploy test service
echo "Deploying test service..."
kubectl apply -f k8s/test-service/

# Deploy Istio configurations
echo "Deploying Istio configurations..."
kubectl apply -f k8s/istio/

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/mitmproxy -n istio-test
kubectl wait --for=condition=available --timeout=120s deployment/test-service -n istio-test

echo ""
echo "Deployment complete!"
echo ""
echo "Verify deployment:"
echo "  kubectl get pods -n istio-test"
echo ""
echo "View Istio proxy status:"
echo "  istioctl proxy-status -n istio-test"
echo ""
echo "Test the setup:"
echo "  ./scripts/test.sh"
