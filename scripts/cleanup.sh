#!/bin/bash

set -e

echo "Cleaning up Istio mesh test resources..."

# Delete Istio configurations
echo "Deleting Istio configurations..."
kubectl delete -f k8s/istio/ --ignore-not-found=true

# Delete test service
echo "Deleting test service..."
kubectl delete -f k8s/test-service/ --ignore-not-found=true

# Delete mitmproxy
echo "Deleting mitmproxy..."
kubectl delete -f k8s/mitmproxy/ --ignore-not-found=true

# Delete namespace
echo "Deleting namespace..."
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true

echo ""
echo "Cleanup complete!"
echo ""
echo "To uninstall Istio completely:"
echo "  istioctl uninstall --purge -y"
echo "  kubectl delete namespace istio-system"
