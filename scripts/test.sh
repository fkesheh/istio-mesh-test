#!/bin/bash

set -e

echo "Testing Istio header-based request interception..."
echo ""

# Get the test service pod
TEST_POD=$(kubectl get pod -n istio-test -l app=test-service -o jsonpath='{.items[0].metadata.name}')

if [ -z "$TEST_POD" ]; then
    echo "Error: test-service pod not found"
    exit 1
fi

echo "Using test pod: $TEST_POD"
echo ""

# Test 1: Request WITH intercept header (should go to mitmproxy)
echo "=========================================="
echo "Test 1: Request WITH X-Intercept header"
echo "Expected: Response from mitmproxy with 'intercepted: true'"
echo "=========================================="
kubectl exec -n istio-test "$TEST_POD" -c test-service -- \
    curl -s -H "X-Intercept: true" http://httpbin.org/get | jq . || \
    kubectl exec -n istio-test "$TEST_POD" -c test-service -- \
    curl -s -H "X-Intercept: true" http://httpbin.org/get

echo ""
echo ""

# Test 2: Request WITHOUT intercept header (should go to external API)
echo "=========================================="
echo "Test 2: Request WITHOUT X-Intercept header"
echo "Expected: Real response from httpbin.org"
echo "=========================================="
kubectl exec -n istio-test "$TEST_POD" -c test-service -- \
    curl -s http://httpbin.org/get | jq . || \
    kubectl exec -n istio-test "$TEST_POD" -c test-service -- \
    curl -s http://httpbin.org/get

echo ""
echo ""

# Test 3: Check mitmproxy logs
echo "=========================================="
echo "Test 3: Mitmproxy logs (recent requests)"
echo "=========================================="
kubectl logs -n istio-test -l app=mitmproxy --tail=20

echo ""
echo "=========================================="
echo "Testing complete!"
echo "=========================================="
