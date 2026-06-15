#!/usr/bin/env bash
set -euo pipefail
q="${1:?question number is required}"

case "$q" in
01) cat <<'EOF'
kubectl --kubeconfig /tmp/cks-prep/q01-kubeconfig config get-contexts -o name \
  > /tmp/cks-prep/q01-output/contexts

kubectl --kubeconfig /tmp/cks-prep/q01-kubeconfig config view --raw \
  -o jsonpath='{.users[?(@.name=="restricted@infra-prod")].user.client-certificate-data}' \
  | base64 -d > /tmp/cks-prep/q01-output/cert

cat /tmp/cks-prep/q01-output/contexts
cat /tmp/cks-prep/q01-output/cert
EOF
;;
02) cat <<'EOF'
Inspect Falco's service logs or configured output and filter by image,
namespace, process, and file. Prefer a custom output format containing only
the four requested fields. Map each offending Pod to its owner:

kubectl get pod POD -n NS -o jsonpath='{.metadata.ownerReferences[0].name}'
kubectl get rs RS -n NS -o jsonpath='{.metadata.ownerReferences[0].name}'
kubectl scale deployment DEPLOYMENT -n NS --replicas=0

Verify both Deployments are at zero and no new matching alerts appear.
EOF
;;
03) cat <<'EOF'
kubectl patch service kubernetes-api -n api-review \
  --type=merge -p '{"spec":{"type":"ClusterIP"}}'
kubectl get service kubernetes-api -n api-review -o yaml

Confirm spec.type is ClusterIP and spec.ports[].nodePort is absent.
EOF
;;
04) cat <<'EOF'
kubectl label namespace team-red \
  pod-security.kubernetes.io/enforce=baseline --overwrite
kubectl delete pod -n team-red -l app=container-host-hacker
kubectl get events -n team-red --sort-by=.lastTimestamp
kubectl get events -n team-red --sort-by=.lastTimestamp \
  | grep -iE 'forbidden|violat|hostPath' > /tmp/cks-prep/q04-events.log
EOF
;;
05) cat <<'EOF'
Run targeted kube-bench checks before and after changes. Typical corrections:

- Set kube-controller-manager --profiling=false in its static Pod manifest.
- Ensure /var/lib/etcd is owned by etcd:etcd where that account is used.
- Set /var/lib/kubelet/config.yaml to mode 600 or stricter.
- Ensure the kubelet uses the cluster CA through authentication.x509.clientCAFile.

Exact check IDs and file locations vary by Kubernetes packaging. Do not copy
historical flags blindly; use the installed benchmark and component config.
EOF
;;
06) cat <<'EOF'
cd /tmp/cks-prep/q06/binaries
sha512sum *
sha512sum -c ../verified.sha512

Remove files not named in the trusted manifest:
rm kube-controller-manager kubelet

sha512sum -c ../verified.sha512
ls -1
EOF
;;
07) cat <<'EOF'
Inspect the ConstraintTemplate schema and the Constraint parameters first.
Usually the smallest fix is adding very-bad-registry.com to the existing
blocked registry parameter list.

kubectl get constrainttemplates
kubectl get constraints
kubectl describe CONSTRAINT_KIND CONSTRAINT_NAME
kubectl run blocked --image=very-bad-registry.com/image --restart=Never

The admission request should be denied, and the existing Deployment should
appear in the constraint's violation status.
EOF
;;
08) cat <<'EOF'
Edit the Dashboard Deployment arguments and Service:

- Remove insecure-port, insecure-bind-address, enable-skip-login, and
  authentication-mode=basic style flags if present.
- Enable HTTPS/certificate generation using flags supported by that image.
- Keep token authentication.
- Change the Service to ClusterIP.

kubectl -n kubernetes-dashboard rollout status deployment
kubectl -n kubernetes-dashboard get service -o wide

Dashboard releases differ significantly, so verify flags using the exact
installed version instead of assuming the historical video flags still exist.
EOF
;;
09) cat <<'EOF'
On the node, validate and load the profile:

sudo apparmor_parser -r /path/to/profile
sudo aa-status
kubectl label node NODE security=apparmor --overwrite

Use nodeSelector security=apparmor. On current Kubernetes, prefer:

securityContext:
  appArmorProfile:
    type: Localhost
    localhostProfile: PROFILE_NAME

On older clusters, the beta annotation may be required. Capture logs with
kubectl logs and verify the Pod is scheduled to the labelled node.
EOF
;;
10) cat <<'EOF'
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc

Set spec.runtimeClassName: gvisor on the Pod and use a nodeSelector matching
the runsc-enabled node. After it is Running:

kubectl exec -n team-purple gvisor-test -- dmesg \
  > /tmp/cks-prep/q10-gvisor-test-dmesg

The output should identify gVisor rather than the host kernel.
EOF
;;
11) cat <<'EOF'
On the control plane, use etcdctl with ETCDCTL_API=3, the etcd endpoint, CA,
client certificate, and client key from the static Pod manifest. Read:

/registry/secrets/team-green/database-access

Store the raw response first. Decode the Secret's pass field separately. Be
aware that raw etcd values use Kubernetes storage encoding and may not be
pleasant text; a simulator may expect strings or JSON output options.
EOF
;;
12) cat <<'EOF'
Confirm the gap:

kubectl auth can-i get secrets --as=system:serviceaccount:restricted:restricted -n restricted
kubectl auth can-i create pods --as=system:serviceaccount:restricted:restricted -n restricted

A Pod created as this ServiceAccount automatically receives its API token and
can mount named Secrets unless admission policy blocks it. Demonstrate using
a short-lived Pod with secretKeyRef or a Secret volume, then write the decoded
values to /tmp/cks-prep/q12/.

Fix by removing unnecessary Pod-create permission and enforcing admission
controls that restrict Secret references and service-account use.
EOF
;;
13) cat <<'EOF'
Get the metadata Service ClusterIP and express it as a /32 ipBlock. Create:

1. A policy selecting all Pods with an egress rule allowing 0.0.0.0/0 except
   the metadata /32. Include DNS egress if your CNI requires explicit rules.
2. A policy selecting role=metadata-accessor with an egress rule allowing the
   metadata /32 and TCP port 80.

NetworkPolicies are additive. Test both Pods with curl and verify ordinary
internet/DNS egress remains available as required.
EOF
;;
14) cat <<'EOF'
Filter Falco events for namespace team-yellow and evt.type=kill, identify Pod
names, then resolve Pod -> ReplicaSet -> Deployment using ownerReferences.
Scale only those Deployments:

kubectl scale deployment DEPLOYMENT -n team-yellow --replicas=0

Verify no matching Pods remain and unrelated Deployments retain their replica counts.
EOF
;;
15) cat <<'EOF'
kubectl create secret tls secure-tls -n team-pink \
  --cert=/path/to/tls.crt --key=/path/to/tls.key
kubectl edit ingress secure -n team-pink

Add:

spec:
  tls:
  - hosts:
    - secure-ingress.test
    secretName: secure-tls

Keep both existing HTTP paths. Verify with curl -kv and inspect the served
certificate subject/fingerprint.
EOF
;;
16) cat <<'EOF'
The resulting file should retain the same five instructions:

FROM alpine:3.12
RUN apk add --no-cache 'nginx>=1.18.0'
RUN adduser -D myuser
USER myuser
CMD ["nginx", "-g", "daemon off;"]

Build if available:
docker build -t image-verify:v2 /tmp/cks-prep/q16

If package pinning fails because the historical Alpine repository no longer
serves a matching package, treat the Dockerfile edit as the exam objective.
EOF
;;
17) cat <<'EOF'
Back up both the API server manifest and audit policy. Set the audit log
max-backup flag to 1. Order audit rules from specific to general:

1. Secrets -> Metadata
2. userGroups: ["system:nodes"] -> RequestResponse
3. level: None

Validate YAML, wait for kube-apiserver recovery, truncate the configured log,
perform test requests, and inspect new entries.
EOF
;;
18) cat <<'EOF'
The p.auster entries name secret-two and secret-five.

for secret in secret-two secret-five; do
  kubectl patch secret "$secret" -n security --type=merge \
    -p "{\"stringData\":{\"password\":\"rotated-$secret\"}}"
done

Decode and verify those two values changed. Confirm secret-one, secret-three,
and secret-four still contain their original values.
EOF
;;
19) cat <<'EOF'
Add to the container:

securityContext:
  readOnlyRootFilesystem: true

Mount an emptyDir volume at /tmp:

volumeMounts:
- name: tmp
  mountPath: /tmp
volumes:
- name: tmp
  emptyDir: {}

Save the edited manifest to the requested path, apply it, then exec into the
Pod. Writing /tmp/test should succeed; writing /test should fail.
EOF
;;
20) cat <<'EOF'
Follow the official kubeadm upgrade sequence for the installed versions:

1. Unhold and upgrade kubeadm on the control plane.
2. Run kubeadm upgrade plan, then kubeadm upgrade apply TARGET.
3. Drain the node, upgrade kubelet and kubectl, restart kubelet, uncordon.
4. Upgrade each worker's kubeadm, run kubeadm upgrade node, then drain and
   upgrade kubelet/kubectl.
5. Verify kubectl get nodes and system Pods.

Never skip minor versions, and use the current Kubernetes package repository instructions.
EOF
;;
21) cat <<'EOF'
For each image, produce machine-readable output and test whether either CVE ID
is present. Example:

trivy image --format json --output result.json IMAGE
jq -e '.. | objects | select(.VulnerabilityID? == "CVE-2020-10878" or .VulnerabilityID? == "CVE-2020-1967")' result.json

Append only images for which the query finds no match. Re-scan and validate
the final file. Historical images may have moved or become unavailable.
EOF
;;
22) cat <<'EOF'
grep -RniE '(password|token|secret|api[_-]?key)' /tmp/cks-prep/q22

Unsafe files:
02-leaked-env.yaml
03-leaked-dockerfile

printf '%s\n' 02-leaked-env.yaml 03-leaked-dockerfile \
  > /tmp/cks-prep/q22-security-issues

Secret references are not themselves plaintext credential exposure.
EOF
;;
23) cat <<'EOF'
Run kube-bench with enough output to identify the exact failing check. Back up
/etc/kubernetes/manifests/kube-controller-manager.yaml, make the narrow flag
change recommended by the installed benchmark, and wait for the static Pod to
restart. Re-run the same check and verify component health.

A common scenario is changing --profiling=true to --profiling=false, but the
benchmark output is the authority.
EOF
;;
24) cat <<'EOF'
Inspect events, then remove privileged mode and satisfy restricted policy:

securityContext:
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
containers:
- name: web
  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]

Because nginx traditionally binds port 80 and writes runtime files, use a
non-root-compatible image/configuration or adjust it to a high port with
writable emptyDir mounts. Keep iterating until rollout status succeeds.
EOF
;;
25) cat <<'EOF'
Create a rule using container and Kubernetes fields with a condition similar to:

container and evt.type in (open, openat, openat2) and fd.name=/dev/mem

Include namespace, Pod, container, process, user, and file in the output.
Validate the rule syntax, reload/restart Falco as required by the installation,
trigger the test workload, and inspect Falco output. Add a namespace condition
only if the task explicitly requires limiting detection to neuron.
EOF
;;
26) cat <<'EOF'
Back up /etc/kubernetes/manifests/kube-apiserver.yaml. Make minimal edits:

- --anonymous-auth=false
- Ensure --authorization-mode includes RBAC (often Node,RBAC).
- Add only the requested admission plugins without deleting required defaults.

Watch the container runtime or kubelet logs while the static Pod restarts.
Verify kubectl access, an unauthenticated request is rejected, and the intended
admission behavior is active.
EOF
;;
27) cat <<'EOF'
Create the TLS Secret, then define an Ingress with:

- ingressClassName set to the Cilium ingress class used by the cluster.
- spec.tls referencing the Secret and hostname.
- A host/path backend to the web Service.
- The Cilium/controller annotation or configuration that enables HTTP-to-HTTPS redirect.

Verify:
curl -I http://HOST
curl -kI https://HOST
openssl s_client -connect HOST:443 -servername HOST

Expect an HTTP redirect, a successful HTTPS response, and the supplied certificate.
EOF
;;
*) echo "Unknown question: $q" >&2; exit 1 ;;
esac
