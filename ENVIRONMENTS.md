# Lab Environments

Not every CKS task can be reproduced safely in a generic shared cluster.

## Environment Levels

| Level | Meaning |
|---|---|
| A | Works on a normal Kubernetes playground with `kubectl`. |
| B | Requires a feature or tool such as Falco, Trivy, Gatekeeper, an ingress controller, AppArmor, or a service mesh. |
| C | Requires SSH/root access to a kubeadm-style node or control plane. |

The setup runner prints the level and checks important prerequisites. Level C
labs should be done only on disposable machines.

## Safety

- Never run host-hardening or control-plane labs on a production cluster.
- Read a setup script before running it with root privileges.
- Recreate the playground if a control-plane task leaves the cluster unhealthy.
- Image scans may need internet access and can take several minutes.

## Recommended Practice Order

1. Complete all Level A labs for speed and Kubernetes fluency.
2. Use a CKS/Killer Shell simulator for Level B and C tasks.
3. Repeat the timed set with no solution notes.
4. Review the official curriculum map and fill any uncovered objectives.
