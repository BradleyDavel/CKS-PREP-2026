#!/usr/bin/env bash
set -euo pipefail

question="${1:?question number is required}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

need_kubectl() {
  command -v kubectl >/dev/null 2>&1 || {
    echo "This lab requires kubectl." >&2
    exit 1
  }
  kubectl cluster-info >/dev/null 2>&1 || {
    echo "kubectl cannot reach a cluster." >&2
    exit 1
  }
}

notice() {
  printf 'Environment level: %s\n%s\n' "$1" "$2"
}

apply() {
  kubectl apply -f -
}

mkdir -p /tmp/cks-prep

case "$question" in
  01)
    notice A "Creates a synthetic kubeconfig so the extraction task is repeatable."
    cert="$(printf 'cks-prep-restricted-certificate' | base64 | tr -d '\n')"
    cat > /tmp/cks-prep/q01-kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- name: infra-prod
  cluster:
    server: https://infra-prod.example.invalid
    certificate-authority-data: $cert
contexts:
- name: infra-prod
  context:
    cluster: infra-prod
    user: restricted@infra-prod
- name: workload-dev
  context:
    cluster: infra-prod
    user: developer
current-context: workload-dev
users:
- name: restricted@infra-prod
  user:
    client-certificate-data: $cert
- name: developer
  user:
    token: practice-only
EOF
    rm -rf /tmp/cks-prep/q01-output
    mkdir -p /tmp/cks-prep/q01-output
    ;;
  03)
    notice A "Creates a deliberately overexposed NodePort service."
    need_kubectl
    kubectl create namespace api-review --dry-run=client -o yaml | apply
    kubectl -n api-review create deployment api-proxy --image=nginx:1.27-alpine --dry-run=client -o yaml | apply
    kubectl -n api-review expose deployment api-proxy --name=kubernetes-api --port=443 --target-port=80 --type=NodePort --dry-run=client -o yaml | apply
    ;;
  04)
    notice A "Creates a workload that violates the baseline Pod Security Standard."
    need_kubectl
    kubectl delete namespace team-red --ignore-not-found --wait=false >/dev/null
    kubectl create namespace team-red
    cat <<'EOF' | apply
apiVersion: apps/v1
kind: Deployment
metadata:
  name: container-host-hacker
  namespace: team-red
spec:
  replicas: 1
  selector:
    matchLabels:
      app: container-host-hacker
  template:
    metadata:
      labels:
        app: container-host-hacker
    spec:
      containers:
      - name: shell
        image: busybox:1.36
        command: ["sh", "-c", "sleep 1d"]
        volumeMounts:
        - name: runtime
          mountPath: /host-run
      volumes:
      - name: runtime
        hostPath:
          path: /run
EOF
    ;;
  06)
    notice A "Creates four fixture binaries and a checksum manifest."
    dir=/tmp/cks-prep/q06
    rm -rf "$dir"
    mkdir -p "$dir/binaries"
    printf 'verified apiserver\n' > "$dir/binaries/kube-apiserver"
    printf 'tampered controller\n' > "$dir/binaries/kube-controller-manager"
    printf 'verified proxy\n' > "$dir/binaries/kube-proxy"
    printf 'tampered kubelet\n' > "$dir/binaries/kubelet"
    (cd "$dir/binaries" && sha512sum kube-apiserver kube-proxy) > "$dir/verified.sha512"
    ;;
  12)
    notice A "Creates a restricted service account with three different permission paths."
    need_kubectl
    kubectl delete namespace restricted --ignore-not-found --wait=false >/dev/null
    kubectl create namespace restricted
    kubectl -n restricted create serviceaccount restricted
    kubectl -n restricted create secret generic secret1 --from-literal=password-key=alpha
    kubectl -n restricted create secret generic secret2 --from-literal=password-key=bravo
    kubectl -n restricted create secret generic secret3 --from-literal=password-key=charlie
    kubectl -n restricted create role pod-reader --verb=get,list,create --resource=pods
    kubectl -n restricted create rolebinding pod-reader --role=pod-reader --serviceaccount=restricted:restricted
    ;;
  13)
    notice A "Creates test Pods and a local metadata-like endpoint."
    need_kubectl
    kubectl delete namespace metadata-access --ignore-not-found --wait=false >/dev/null
    kubectl create namespace metadata-access
    kubectl -n metadata-access create deployment metadata-server --image=nginx:1.27-alpine
    kubectl -n metadata-access expose deployment metadata-server --port=80
    kubectl -n metadata-access run ordinary --image=curlimages/curl:8.10.1 --command -- sleep 1d
    kubectl -n metadata-access run accessor --labels=role=metadata-accessor --image=curlimages/curl:8.10.1 --command -- sleep 1d
    ;;
  16)
    notice A "Creates an intentionally weak Dockerfile for offline editing."
    dir=/tmp/cks-prep/q16
    rm -rf "$dir"
    mkdir -p "$dir"
    cat > "$dir/Dockerfile" <<'EOF'
FROM alpine:3.9
RUN apk add --no-cache nginx=1.14.2-r0 curl
RUN adduser -D myuser
USER root
CMD ["nginx", "-g", "daemon off;"]
EOF
    ;;
  18)
    notice A "Creates audit-log fixtures and confidential Secrets."
    need_kubectl
    kubectl create namespace security --dry-run=client -o yaml | apply
    for n in one two three four five; do
      kubectl -n security create secret generic "secret-$n" --from-literal=password="old-$n" --dry-run=client -o yaml | apply
    done
    cp "$repo_root/fixtures/q18-audit.log" /tmp/cks-prep/q18-audit.log
    ;;
  19)
    notice A "Creates a mutable Deployment and exports its manifest."
    need_kubectl
    kubectl create namespace team-purple --dry-run=client -o yaml | apply
    kubectl -n team-purple create deployment immutable-deployment --image=nginx:1.27-alpine --dry-run=client -o yaml | apply
    kubectl -n team-purple get deployment immutable-deployment -o yaml > /tmp/cks-prep/q19-deployment.yaml
    ;;
  22)
    notice A "Creates YAML and Dockerfile fixtures containing mixed credential issues."
    rm -rf /tmp/cks-prep/q22
    cp -R "$repo_root/fixtures/q22" /tmp/cks-prep/q22
    ;;
  24)
    notice A "Creates a Deployment that violates the restricted Pod Security Standard."
    need_kubectl
    kubectl delete namespace restricted-workloads --ignore-not-found --wait=false >/dev/null
    kubectl create namespace restricted-workloads
    cat <<'EOF' | apply
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: restricted-workloads
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        securityContext:
          privileged: true
EOF
    kubectl label namespace restricted-workloads pod-security.kubernetes.io/enforce=restricted --overwrite
    kubectl -n restricted-workloads delete pod -l app=web --ignore-not-found
    ;;
  *)
    level="$(awk -F'|' -v n="$question" '$1 == n {print $3}' "$repo_root/scripts/questions.index")"
    notice "${level:-B}" "This scenario needs capabilities a generic playground cannot create safely. The question file lists the exact prerequisites and practice target."
    ;;
esac

echo "Setup complete."
