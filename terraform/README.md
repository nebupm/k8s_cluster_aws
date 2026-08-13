<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ./modules/load_balancer | n/a |
| <a name="module_security_groups"></a> [security\_groups](#module\_security\_groups) | ./modules/security_groups | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | IAM role ARN to assume for multi-account deployments. Null uses default credentials. | `string` | `null` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of AZs to deploy nodes across. | `list(string)` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Local AWS SSO profile. Set to null in CI/CD pipelines. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy into. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Unique name for this Kubernetes cluster (e.g. ntegra-payments-prod). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment. | `string` | n/a | yes |
| <a name="input_manager_nodes"></a> [manager\_nodes](#input\_manager\_nodes) | Control plane node definitions. Key is a unique node ID. Add entries to scale out. | <pre>map(object({<br/>    instance_type = string<br/>    disk_size_gb  = number<br/>    az_index      = number<br/>  }))</pre> | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for private subnets (one per AZ, used by nodes). | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets (one per AZ, used by ALB). | `list(string)` | n/a | yes |
| <a name="input_ssh_allowed_cidr"></a> [ssh\_allowed\_cidr](#input\_ssh\_allowed\_cidr) | CIDR allowed SSH access. Restrict to office/VPN IP in production. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | Name of the EC2 key pair for node access. | `string` | n/a | yes |
| <a name="input_tag_what"></a> [tag\_what](#input\_tag\_what) | Tag: what these resources are. | `string` | n/a | yes |
| <a name="input_tag_who"></a> [tag\_who](#input\_tag\_who) | Tag: team or individual responsible for these resources. | `string` | n/a | yes |
| <a name="input_tag_why"></a> [tag\_why](#input\_tag\_why) | Tag: why these resources exist. | `string` | n/a | yes |
| <a name="input_team"></a> [team](#input\_team) | Team or function that owns this cluster (e.g. payments, platform). | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC. Must be unique per cluster when deploying in the same account. | `string` | n/a | yes |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node definitions. Key is a unique node ID. Add entries to scale out. | <pre>map(object({<br/>    instance_type = string<br/>    disk_size_gb  = number<br/>    az_index      = number<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | Public ALB DNS for application traffic. |
| <a name="output_api_nlb_dns_name"></a> [api\_nlb\_dns\_name](#output\_api\_nlb\_dns\_name) | Internal NLB DNS — set as kubeadm --control-plane-endpoint. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name — used by generate\_inventory.sh to name the inventory file. |
| <a name="output_cp_instance_ids"></a> [cp\_instance\_ids](#output\_cp\_instance\_ids) | Map of control plane node key to instance ID (needed for SSM). |
| <a name="output_cp_private_ips"></a> [cp\_private\_ips](#output\_cp\_private\_ips) | Map of control plane node key to private IP. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
| <a name="output_worker_instance_ids"></a> [worker\_instance\_ids](#output\_worker\_instance\_ids) | Map of worker node key to instance ID (needed for SSM). |
| <a name="output_worker_private_ips"></a> [worker\_private\_ips](#output\_worker\_private\_ips) | Map of worker node key to private IP. |
<!-- END_TF_DOCS -->