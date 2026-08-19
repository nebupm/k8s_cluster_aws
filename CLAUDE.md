# CLAUDE.md — K8s Cluster AWS

> **Full requirements, design rationale, and scaling rules**: see [`requirements.md`](requirements.md).

## Repository layout

```
terraform/
├── modules/               # Shared modules — vpc, security_groups, iam, compute, load_balancer, keys
├── environments/          # One .tfvars per cluster (team × environment)
├── backends/              # One .hcl per cluster — S3 bucket + state key
├── bootstrap/             # Creates one S3 state bucket per env tier (run once)
├── scripts/
│   ├── generate_inventory.sh
│   └── run_tflint.sh      # Wrapper — passes absolute .tflint.hcl path to tflint --recursive
├── main.tf                # Module wiring — never changes per cluster
├── variables.tf           # All variable declarations
├── providers.tf           # AWS provider with optional assume_role
└── terraform.tf           # Partial S3 backend (populated at init time)

ansible/
├── roles/
│   ├── common/            # containerd, kubelet, kubeadm, kubectl, sysctl
│   ├── k8s_control_plane/ # kubeadm init + join
│   └── k8s_worker/        # kubeadm join
├── group_vars/all.yml
└── site.yml
```

## Core design rule

**Code never changes when adding a cluster. Only data files multiply.**

| File | Count |
|---|---|
| `environments/<team>-<env>.tfvars` | 1 per cluster |
| `backends/<team>-<env>.hcl` | 1 per cluster |
| Everything else | 1 total, shared |

Adding a new cluster = copy a `.tfvars` + a `.hcl`, update the values, `terraform init && apply`. No changes to modules or `main.tf`.

## Key constraints

- **VPC CIDRs must be unique per cluster** when clusters share an AWS account — use distinct `10.x.0.0/16` blocks
- **Terraform ≥ 1.13** required — uses S3 native locking (`use_lockfile = true`), no DynamoDB
- **No hardcoded cluster names** in modules or playbooks — always use `var.cluster_name` or dynamic group references
- **Kubeconfig files must never be committed** — `*.kubeconfig` is in `.gitignore`
- **`environment` must be one of** `dev`, `staging`, `prod` — enforced by variable validation
- **Bootstrap workspace must match `var.environment`** — enforced by validation; prevents applying to wrong tier

## Authentication

- **Local runs**: `export AWS_PROFILE=<sso-profile> && aws sso login --profile <sso-profile>` — picked up by both the provider and the S3 backend
- **`aws_profile` in `.tfvars`**: optional provider-level override; does not apply to the backend
- **CI/CD**: leave `aws_profile = null` — the runner IAM role is used
- **Multi-account**: set `assume_role_arn` in the cluster's `.tfvars`; leave `null` for single-account

## Terraform workflow per cluster

```bash
# Authenticate (local only)
export AWS_PROFILE=ntegra-sso-adm
aws sso login --profile ntegra-sso-adm

# Point at the cluster's backend and apply
cd terraform
terraform init -backend-config=backends/<team>-<env>.hcl
terraform plan  -var-file=environments/<team>-<env>.tfvars
terraform apply -var-file=environments/<team>-<env>.tfvars

# Switch cluster
terraform init -reconfigure -backend-config=backends/<other-team>-<other-env>.hcl
terraform apply -var-file=environments/<other-team>-<other-env>.tfvars
```

## Bootstrap (one time per environment tier)

```bash
cd terraform/bootstrap
terraform init
terraform workspace new dev
terraform apply -var="environment=dev" -var="aws_region=eu-west-2" -var="tag_who=ntegra"
# Repeat for staging and prod workspaces
# Copy each state_bucket_name output into the corresponding backends/*.hcl files
```

## Ansible workflow

```bash
# Generate inventory from current Terraform outputs
terraform/scripts/generate_inventory.sh
# Writes ansible/inventory-<cluster_name>.ini

# Configure the cluster
cd ansible
ansible-playbook -i inventory-<cluster_name>.ini site.yml
```

## Tagging

All resources are tagged via `provider default_tags` in `providers.tf`. Tags are sourced from variables — never hardcode tags in module resources.

| Tag | Source |
|---|---|
| `Cluster` | `var.cluster_name` |
| `Environment` | `var.environment` |
| `Team` | `var.team` |
| `ManagedBy` | hardcoded `"terraform"` |
| `Who` / `What` / `Why` | `.tfvars` |

## Pre-commit hooks

Hooks run on every commit: `terraform fmt`, `terraform validate` (root + bootstrap), `tflint`, `terraform-docs`.

```bash
pre-commit install          # one time after cloning
pre-commit run --all-files  # run manually
```

`terraform init` must be run in `terraform/` and `terraform/bootstrap/` before the validate hooks will pass. If not initialised, validate hooks skip gracefully rather than blocking the commit.

The `tflint` hook calls `terraform/scripts/run_tflint.sh`, which resolves an absolute path to `.tflint.hcl` — required because `tflint --recursive` resolves `--config` relative to each subdirectory it descends into.

## SSH key management

Keys are fully Terraform-managed — no manual generation or Console steps.

| Step | What happens |
|---|---|
| `terraform apply` | `modules/keys` generates ED25519 key, creates EC2 Key Pair, stores private key in SSM Parameter Store (`SecureString`) at `/<cluster_name>/ssh-private-key` |
| `generate_inventory.sh` | Retrieves private key from SSM (`aws ssm get-parameter --with-decryption`) → writes to `~/.ssh/<cluster_name>` (chmod 600) |
| Ansible | Uses `~/.ssh/<cluster_name>` via `ansible_ssh_private_key_file` in the inventory |

Keys are stable across scale operations — Terraform only creates them once; `lifecycle { ignore_changes = [value] }` prevents regeneration. Scale out/in only touches `aws_instance` resources.

SSM Parameter Store SecureString is free for standard parameters (< 4 KB). Do not switch to Secrets Manager — it costs $0.40/secret/month with no security benefit for this use case.

The private key is also in Terraform state (encrypted in S3 via AES256). Access to the state bucket must be restricted via IAM.

## What not to do

- Do not hardcode cluster names, IPs, or hostnames in modules or playbooks
- Do not edit `main.tf` or `variables.tf` to add a new cluster — use `.tfvars`
- Do not commit `*.kubeconfig` files
- Do not set `ssh_allowed_cidr = "0.0.0.0/0"` in staging or prod
- Do not hardcode the AWS profile in `backends/*.hcl` — CI/CD runners use IAM roles
- Do not run `terraform apply` without specifying `-var-file` — the root module has no defaults for cluster-specific variables
- Do not manually create or import EC2 key pairs — the `keys` module manages them
- Do not commit `*.pem`, `*.key`, `id_ed25519*`, or any private key files
- Do not commit `ansible/inventory-*.ini` — these are generated files containing private IPs and instance IDs
