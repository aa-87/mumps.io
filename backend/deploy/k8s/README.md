# Kubernetes notes

These manifests assume you have a container image that:
- contains YottaDB
- contains your routines under the routines path configured by `gtmroutines`
- runs the server using `yottadb -run MIO`

## Apply
- `kubectl apply -f deploy/k8s/00-namespace.yaml`
- `kubectl apply -f deploy/k8s/10-configmap.yaml`
- `kubectl apply -f deploy/k8s/20-deployment.yaml`
- `kubectl apply -f deploy/k8s/30-service.yaml`
- `kubectl apply -f deploy/k8s/40-ingress.yaml`
- Optional: `kubectl apply -f deploy/k8s/50-hpa.yaml`

## Notes on client IP
If you use an ingress controller and want rate limiting by real client IP, set:
- `server.rate.trustProxy=1` in config
and ensure the proxy is trusted.

