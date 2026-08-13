# K8s Lab Cluster Requirements

## 1. Goal

Provision and manage multiple independent, production-like Kubernetes clusters on AWS using a single Terraform codebase and Ansible for cluster configuration. The framework must support any combination of teams, environments, and AWS accounts without duplicating infrastructure code.

## 2. Infrastructure State

- **Platform**: AWS EC2 (Amazon Linux 2023, resolved via AMI data source)
- **Networking**:
  - Custom VPC with 3 public subnets (ALB) and 3 private subnets (nodes) across 3 AZs
  - Nodes have no public IPs — accessed via AWS SSM (no bastion host)
  - VPC CIDRs must be unique per cluster when deploying into the same AWS account
- **Node Access**: IAM instance profile with `AmazonSSMManagedInstanceCore`
- **Config**: All cluster parameters driven by `terraform/environments/<team>-<env>.tfvars`
- **State**: Remote state in S3 with native S3 locking (`use_lockfile = true`, requires Terraform ≥ 1.13)

## 3. Multi-Cluster Design

### Guiding Principle

Every cluster has the same shape — VPC, security groups, IAM, compute, load balancer. What differs between clusters is only the **values**: node sizes, counts, CIDRs, tags, AWS account. The infrastructure code stays constant; variable files drive everything.

### What scales with cluster count

| File | Count | Contains |
|---|---|---|
| `environments/<team>-<env>.tfvars` | 1 per cluster | Node sizes, counts, CIDRs, tags |
| `backends/<team>-<env>.hcl` | 1 per cluster | S3 bucket name + state key (3 lines) |
| `main.tf` | 1 total | Module wiring — never changes |
| `variables.tf` | 1 total | Variable declarations |
| `modules/` | 1 set | Reusable infrastructure components |

Adding a new cluster = add one `.tfvars` + one `.hcl` file, then `terraform init && apply`.

### State isolation

One S3 bucket per environment tier, shared across all teams in that tier. State keys are namespaced by team:

```
ntegra-k8s-dev-tfstate/
  platform/dev/terraform.tfstate
  payments/dev/terraform.tfstate

ntegra-k8s-prod-tfstate/
  platform/prod/terraform.tfstate
  payments/prod/terraform.tfstate
```

The `bootstrap/` module creates one bucket per tier using Terraform workspaces (run once per tier).

### Multi-account support

The provider accepts an optional `assume_role_arn` variable. Per cluster in `.tfvars`:

```hcl
assume_role_arn = "arn:aws:iam::111122223333:role/TerraformRole"  # prod account
assume_role_arn = null                                             # dev — use default credentials
```

No code changes are needed when adding a new AWS account.

## 4. Load Balancers

| Load Balancer | Type | Scope | Purpose |
|---|---|---|---|
| `<cluster>-api-nlb` | Network (NLB) | Internal | k8s API HA — port 6443 → control plane nodes |
| `<cluster>-app-alb` | Application (ALB) | Internet-facing | App ingress — port 80 → worker nodes |

The NLB DNS name is injected into the Ansible inventory and used as `--control-plane-endpoint` in `kubeadm init`.

## 5. Core Objectives

### Infrastructure (Terraform)

- Modular structure: `vpc`, `security_groups`, `iam`, `compute`, `load_balancer` — written once, shared by all clusters
- Config-driven via `.tfvars` — adding a node = adding a map entry + `terraform apply`
- Bootstrap module creates one S3 state bucket per environment tier (workspace-driven, run once)
- `generate_inventory.sh` reads `cluster_name` from Terraform output and writes `ansible/inventory-<cluster_name>.ini`

### Cluster Configuration (Ansible)

- **k8s version**: 1.30
- **Container runtime**: containerd
- **CNI**: Flannel (`10.244.0.0/16`)
- **HA control plane**: 3 nodes joined via `kubeadm init --upload-certs`
- Roles: `common` (containerd, kubelet, kubeadm, kubectl, sysctl), `k8s_control_plane`, `k8s_worker`
- Playbooks use dynamic group references — no hardcoded hostnames

### Tagging

All resources are tagged via `provider default_tags`. Standard tags per cluster:

| Tag | Source | Example |
|---|---|---|
| `Cluster` | `var.cluster_name` | `ntegra-platform-prod` |
| `Environment` | `var.environment` | `prod` |
| `Team` | `var.team` | `platform` |
| `ManagedBy` | hardcoded | `terraform` |
| `Who` / `What` / `Why` | `.tfvars` | team-specific |

### Validation

- `environment` must be one of `dev`, `staging`, `prod`
- Bootstrap enforces `var.environment == terraform.workspace` to prevent applying to the wrong tier
- `ssh_allowed_cidr` defaults to open; must be restricted to office/VPN IP in production

## 6. Scaling

- **Scale out**: Add an entry to `manager_nodes` or `worker_nodes` in the cluster's `.tfvars`, run `terraform apply` — only the new node is affected
- **Scale in**: Remove the entry and re-apply; drain the node in Kubernetes first
- **New cluster**: Add one `.tfvars` + one `.hcl`, `terraform init -backend-config=...`, `terraform apply -var-file=...`
- **New team**: Same as new cluster — no changes to shared code

## 7. Cluster Access

- Kubeconfig extracted from the first control plane node via SSM (`sudo cat /etc/kubernetes/admin.conf`)
- `server:` field updated to the NLB DNS name for HA API access
- Supports isolated (`KUBECONFIG=...`), merged, or `direnv`-based context management
- Kubeconfig files must not be committed to the repository
