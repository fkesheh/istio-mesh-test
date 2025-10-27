# Istio Mesh Test - Header-Based Request Interception POC

This POC demonstrates Istio intercepting outbound requests based on a custom header and routing them through mitmproxy.

## Architecture

1. **Test Service** - A simple Python service that makes HTTP calls to an external API
2. **Istio Service Mesh** - Intercepts outbound traffic based on headers
3. **Mitmproxy** - Acts as a mock service that returns custom responses
4. **External API** - Real external service (httpbin.org used for testing)

## Flow

- **With intercept header** (`X-Intercept: true`):
  - Service ’ Istio Sidecar ’ VirtualService routes to mitmproxy ’ Mock response

- **Without intercept header**:
  - Service ’ Istio Sidecar ’ External API (httpbin.org)

## Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl configured to use docker-desktop context
- Istio installed on the cluster

## Quick Start

```bash
# 1. Install Istio (if not already installed)
./scripts/install-istio.sh

# 2. Deploy all components
./scripts/deploy.sh

# 3. Test the setup
./scripts/test.sh
```

## Manual Testing

```bash
# Get the test service pod
kubectl get pods -n istio-test

# Test WITH intercept header (should go to mitmproxy)
kubectl exec -n istio-test deploy/test-service -c test-service -- \
  curl -H "X-Intercept: true" http://httpbin.org/get

# Test WITHOUT intercept header (should go to external API)
kubectl exec -n istio-test deploy/test-service -c test-service -- \
  curl http://httpbin.org/get
```

## Components

- `k8s/namespace.yaml` - Namespace with Istio injection enabled
- `k8s/mitmproxy/` - Mitmproxy deployment and configuration
- `k8s/test-service/` - Test service deployment
- `k8s/istio/` - Istio VirtualService and ServiceEntry configurations
- `scripts/` - Helper scripts for deployment and testing

## Cleanup

```bash
./scripts/cleanup.sh
```
