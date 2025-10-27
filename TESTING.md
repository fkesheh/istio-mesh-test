# Testing Results

## POC Summary

This POC successfully demonstrates Istio intercepting outbound HTTP requests based on a custom header (`X-Intercept`) and routing them to an internal mock service.

## Architecture

```
┌──────────────┐
│ Test Service │
│ (w/ sidecar) │
└──────┬───────┘
       │
       ├─── With X-Intercept: true ────┐
       │                                │
       │                                ▼
       │                     ┌───────────────────┐
       │                     │   Mock Service    │
       │                     │   (Python HTTP)   │
       │                     └───────────────────┘
       │                                │
       │                                ▼
       │                      Returns: {"intercepted": true}
       │
       │
       ├─── Without header ────────────┐
       │                                │
       │                                ▼
       │                     ┌───────────────────┐
       │                     │  External API     │
       │                     │  (httpbin.org)    │
       │                     └───────────────────┘
       │                                │
       │                                ▼
       │                      Returns: Real httpbin.org response
```

## Test Results

### Test 1: With Intercept Header ✅

**Command:**
```bash
kubectl exec -n istio-test deploy/test-service -c test-service -- \
  curl -H "X-Intercept: true" http://httpbin.org/get
```

**Result:**
```json
{
  "intercepted": true,
  "message": "This response was intercepted by the mock service!",
  "path": "/get",
  "method": "GET",
  "headers": {...},
  "mock_service": "active"
}
```

✅ **SUCCESS** - Request was intercepted by the internal mock service

### Test 2: Without Intercept Header ✅

**Command:**
```bash
kubectl exec -n istio-test deploy/test-service -c test-service -- \
  curl http://httpbin.org/get
```

**Result:**
```json
{
  "args": {},
  "headers": {...},
  "origin": "200.163.211.37",
  "url": "http://httpbin.org/get"
}
```

✅ **SUCCESS** - Request went to the real external httpbin.org API

## How It Works

1. **ServiceEntry** (`k8s/istio/serviceentry.yaml`): Defines httpbin.org as an external service
2. **VirtualService** (`k8s/istio/virtualservice.yaml`): Routes traffic based on headers:
   - If `X-Intercept: true` → Route to `mitmproxy.istio-test.svc.cluster.local:8080`
   - Otherwise → Route to external `httpbin.org:80`
3. **Mock Service** (`k8s/mitmproxy/`): Python HTTP server that returns mocked responses
4. **Test Service** (`k8s/test-service/`): Curl container with Istio sidecar for testing

## Verification Commands

```bash
# Check all components are running
kubectl get pods -n istio-test

# Check Istio configuration
kubectl get virtualservice,serviceentry -n istio-test

# View Istio proxy configuration
istioctl proxy-config routes deploy/test-service -n istio-test

# Check mock service logs
kubectl logs -n istio-test -l app=mitmproxy -c mock-service
```

## Cleanup

```bash
./scripts/cleanup.sh
```
