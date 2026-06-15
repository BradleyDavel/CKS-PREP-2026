#!/usr/bin/env bash
set -euo pipefail
q="${1:?question number is required}"

case "$q" in
01) cat <<'EOF'
Environment: A
Source: https://youtu.be/Jd_j2wruz6E

Use the kubeconfig at /tmp/cks-prep/q01-kubeconfig.

1. Write every context name to /tmp/cks-prep/q01-output/contexts, one per line.
2. Extract and decode the client certificate for restricted@infra-prod.
3. Save the decoded certificate bytes to /tmp/cks-prep/q01-output/cert.
EOF
;;
02) cat <<'EOF'
Environment: B - Falco must be installed and collecting container events.
Source: https://youtu.be/8jYs7S5WPGo

Investigate the Falco events and identify:

1. An nginx workload starting package-management processes.
2. An httpd workload modifying /etc/passwd.
3. Save at least 30 seconds of matching nginx events to
   /tmp/cks-prep/q02-falco.log using only:
   timestamp,container-id,container-name,user-name
4. Scale both owning Deployments to zero.
EOF
;;
03) cat <<'EOF'
Environment: A
Source: https://youtu.be/DuJkyZMMbXc

The Service api-review/kubernetes-api unnecessarily exposes an API proxy
outside the cluster.

Change it so it is reachable only through a ClusterIP. Preserve its selector
and service ports, then verify that no nodePort remains.
EOF
;;
04) cat <<'EOF'
Environment: A
Source: https://youtu.be/fCXizTOpFTw

The Deployment team-red/container-host-hacker mounts a host runtime directory.

1. Enforce the baseline Pod Security Standard on Namespace team-red.
2. Delete the existing Pod.
3. Confirm the ReplicaSet cannot recreate the violating Pod.
4. Save the relevant warning event lines to /tmp/cks-prep/q04-events.log.
EOF
;;
05) cat <<'EOF'
Environment: C - disposable kubeadm control-plane and worker nodes with kube-bench.
Source: https://youtu.be/EtmNz6jotYk

Use kube-bench and the CIS recommendations to check and, if needed, correct:

1. kube-controller-manager profiling.
2. Ownership of /var/lib/etcd.
3. Permissions of /var/lib/kubelet/config.yaml.
4. The kubelet client CA configuration.

Back up every host file before editing it.
EOF
;;
06) cat <<'EOF'
Environment: A
Source: https://youtu.be/hgK7ZUsfndg

The directory /tmp/cks-prep/q06/binaries contains four Kubernetes-like
binaries. The trusted hashes are in /tmp/cks-prep/q06/verified.sha512.

Delete every binary that does not have a trusted SHA-512 checksum. Leave only
the verified files and prove the remaining checksums match.
EOF
;;
07) cat <<'EOF'
Environment: B - OPA Gatekeeper and an existing registry constraint are required.
Source: https://youtu.be/34nOm71RcLo

Extend the existing allowed/blocked registry policy so images from
very-bad-registry.com are rejected.

Verify both a directly created Pod and an existing Deployment violation. Do
not solve this by deleting the workload or changing its image.
EOF
;;
08) cat <<'EOF'
Environment: B - Kubernetes Dashboard must be installed.
Source: https://youtu.be/Q7JNLgtlwnc

Harden the Dashboard:

1. Remove skip-login and basic-auth behavior.
2. Disable insecure HTTP serving.
3. Enable automatic certificate generation and HTTPS.
4. Require token authentication compatible with RBAC.
5. Expose the Dashboard only inside the cluster.

Note: flags differ by Dashboard version; inspect the running image and help output.
EOF
;;
09) cat <<'EOF'
Environment: C - Linux node with AppArmor enabled and node access.
Source: https://youtu.be/euuQH7R1KpQ

1. Load the profile supplied by your simulator onto the target node.
2. Label that node security=apparmor.
3. Create Deployment default/apparmor with one nginx container scheduled to
   that node and using the profile.
4. Save the resulting container logs to /tmp/cks-prep/q09-logs.

Use the AppArmor field supported by the cluster's Kubernetes version.
EOF
;;
10) cat <<'EOF'
Environment: C - a worker configured with the runsc/gVisor containerd runtime.
Source: https://youtu.be/EO2RQmhHPew

1. Create RuntimeClass gvisor with handler runsc.
2. Create Pod team-purple/gvisor-test using nginx and that RuntimeClass.
3. Pin the Pod to the node that supports runsc.
4. Save dmesg output from inside the running Pod to
   /tmp/cks-prep/q10-gvisor-test-dmesg.
EOF
;;
11) cat <<'EOF'
Environment: C - kubeadm control-plane access and etcdctl are required.
Source: https://youtu.be/VS3mysrgA2w

Read Secret team-green/database-access directly from etcd, not through
kubectl get secret.

Save the complete etcd response to /tmp/cks-prep/q11-etcd-secret-content and
save the decoded value of key pass to /tmp/cks-prep/q11-database-password.
EOF
;;
12) cat <<'EOF'
Environment: A
Source: https://youtu.be/mul1YPi9iq0

Audit the permissions of ServiceAccount restricted/restricted. It should not
be able to read Secrets directly, but can create Pods.

Use Kubernetes authorization checks to determine whether a Pod-based
permission escape is possible. Demonstrate the risk using secret1, secret2,
and secret3, then save their decoded password-key values under
/tmp/cks-prep/q12/. Finally, document the RBAC fix.
EOF
;;
13) cat <<'EOF'
Environment: A - the cluster CNI must enforce NetworkPolicy.
Source: https://youtu.be/GgWUkw-q9sw

In Namespace metadata-access:

1. Create NetworkPolicy metadata-deny that blocks all Pods from reaching the
   metadata-server endpoint while preserving other egress.
2. Create NetworkPolicy metadata-allow that permits only Pods labelled
   role=metadata-accessor to reach that endpoint.
3. Test with the existing ordinary and accessor Pods.

Adapt the original IP-based scenario to the Service IP created by this lab.
EOF
;;
14) cat <<'EOF'
Environment: B - Falco must be installed and collecting syscall events.
Source: https://youtu.be/R31JFzuMVMw

Investigate workloads in Namespace team-yellow. Find Pods whose processes use
the forbidden kill syscall. Identify each owning Deployment and scale only
those Deployments to zero. Preserve unrelated workloads.
EOF
;;
15) cat <<'EOF'
Environment: B - an ingress controller and test hostname routing are required.
Source: https://youtu.be/rPuNoh56E9w

An Ingress named team-pink/secure routes /app and /api but currently uses its
controller's default certificate.

Create a TLS Secret from the supplied certificate and key, reference it from
the Ingress, preserve both routes, and verify HTTPS presents the supplied
certificate.
EOF
;;
16) cat <<'EOF'
Environment: A - Docker or another image builder is optional for verification.
Source: https://youtu.be/zrr0aLMnJ04

Edit /tmp/cks-prep/q16/Dockerfile without adding new instructions:

1. Use alpine:3.12 as the base.
2. Do not install curl.
3. Change nginx to a version constraint of at least 1.18.0.
4. Run the main process as myuser.

If an image builder is available, build and tag the result as
image-verify:v2.
EOF
;;
17) cat <<'EOF'
Environment: C - kubeadm control-plane access with audit logging enabled.
Source: https://youtu.be/O80HmhOGBsY

1. Configure the API server to keep only one audit log backup.
2. Change the audit policy so Secret resources log at Metadata level.
3. Log requests from group system:nodes at RequestResponse level.
4. Drop other events with a final None rule.
5. Truncate the current audit log and verify only the new policy is represented.
EOF
;;
18) cat <<'EOF'
Environment: A
Source: https://youtu.be/uFLZNI_ZyGQ

Review /tmp/cks-prep/q18-audit.log and identify which Secrets were accessed by
ServiceAccount security/p.auster.

Change the password value only for those Secrets. Do not rotate Secrets that
were accessed by other identities or not accessed at all.
EOF
;;
19) cat <<'EOF'
Environment: A
Source: https://youtu.be/Mm7sR3untic

Harden Deployment team-purple/immutable-deployment so:

1. The container root filesystem is read-only.
2. /tmp remains writable through an ephemeral volume.
3. The image is unchanged.

Save the updated manifest to /tmp/cks-prep/q19-deployment-new.yaml, apply it,
and verify writes fail outside /tmp.
EOF
;;
20) cat <<'EOF'
Environment: C - disposable kubeadm control-plane and worker nodes.
Source: https://youtu.be/e0eoEXSkpQY

Practice a supported one-minor-version Kubernetes upgrade with apt and kubeadm:

1. Check the current and target versions.
2. Upgrade the control plane first.
3. Drain, upgrade, and uncordon each node safely.
4. Upgrade kubelet and kubectl packages.
5. Verify node versions and workload health.

Use versions available in your lab repository rather than the historical
versions shown in the source video.
EOF
;;
21) cat <<'EOF'
Environment: B - Trivy and image registry access are required.
Source: https://youtu.be/oPhUIBI_Ku4

Scan these historical practice images:

- nginx:1.16.1-alpine
- registry.k8s.io/kube-apiserver:v1.18.0
- registry.k8s.io/kube-controller-manager:v1.18.0
- docker.io/weaveworks/weave-kube:2.7.0

Write images that contain neither CVE-2020-10878 nor CVE-2020-1967 to
/tmp/cks-prep/q21-good-images, one per line.
EOF
;;
22) cat <<'EOF'
Environment: A
Source: https://youtu.be/tKWjGAsHPvE

Perform a manual static review of files under /tmp/cks-prep/q22. Find files
that expose credentials directly in a manifest or image build definition.

Write only the unsafe filenames to /tmp/cks-prep/q22-security-issues, one per
line. Running as root is outside the scope of this task.
EOF
;;
23) cat <<'EOF'
Environment: C - disposable kubeadm control plane with kube-bench.
Source: https://youtu.be/66FqzR7W2qw

Run the relevant CIS control-plane checks, identify the failing
kube-controller-manager recommendation, back up its static Pod manifest, and
correct the insecure setting. Wait for the component to restart and rerun the
same kube-bench check to prove it passes.
EOF
;;
24) cat <<'EOF'
Environment: A
Source: https://youtu.be/XQPiev_u30k

Namespace restricted-workloads enforces the restricted Pod Security Standard,
and Deployment web cannot create a compliant Pod.

Modify the Pod template to satisfy restricted policy while keeping nginx
functional. Use namespace events to discover every violation, then verify the
Deployment becomes Available.
EOF
;;
25) cat <<'EOF'
Environment: B - Falco must be installed with permission to monitor the node.
Source: https://youtu.be/rnzmQqD_2Gg

Create a Falco rule that detects a container in Namespace neuron attempting
to open /dev/mem through open, openat, or openat2.

Include useful Kubernetes and container fields in the output, load the rule,
trigger the supplied suspicious workload, and prove the alert fires without
matching ordinary file access.
EOF
;;
26) cat <<'EOF'
Environment: C - disposable kubeadm control plane.
Source: https://youtu.be/Roa5sjKY0po

Harden the kube-apiserver static Pod manifest:

1. Disable anonymous authentication.
2. Ensure RBAC authorization is enabled.
3. Enable the admission controls required by the scenario.
4. Preserve existing valid flags and certificates.
5. Wait for the API server to recover and verify the effective configuration.

Back up the manifest before editing it.
EOF
;;
27) cat <<'EOF'
Environment: B - Cilium ingress support and a resolvable test hostname.
Source: https://youtu.be/cx7E795zFJs

Expose a web application through a Cilium-managed Ingress:

1. Configure TLS with the supplied certificate and key.
2. Serve the application over HTTPS.
3. Force HTTP requests to redirect to HTTPS.
4. Verify the certificate, response, and redirect behavior with curl.
EOF
;;
*) echo "Unknown question: $q" >&2; exit 1 ;;
esac
