#!/bin/bash
# Generates ansible/inventory-<cluster_name>.ini from Terraform outputs and
# retrieves the cluster SSH private key from AWS Secrets Manager into ~/.ssh/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ANSIBLE_DIR="$(cd "${TF_DIR}/../ansible" && pwd)"

for cmd in jq aws terraform; do
  if ! command -v "${cmd}" &>/dev/null; then
    echo "ERROR: '${cmd}' is required but not installed." >&2
    exit 1
  fi
done

echo "Reading Terraform outputs from ${TF_DIR}..."
TF_OUTPUT=$(terraform -chdir="${TF_DIR}" output -json)

CLUSTER_NAME=$(echo "${TF_OUTPUT}"    | jq -r '.cluster_name.value')
API_ENDPOINT=$(echo "${TF_OUTPUT}"    | jq -r '.api_nlb_dns_name.value')
CP_IPS=$(echo "${TF_OUTPUT}"          | jq -r '.cp_private_ips.value')
WORKER_IPS=$(echo "${TF_OUTPUT}"      | jq -r '.worker_private_ips.value')
CP_IDS=$(echo "${TF_OUTPUT}"          | jq -r '.cp_instance_ids.value')
WORKER_IDS=$(echo "${TF_OUTPUT}"      | jq -r '.worker_instance_ids.value')
SSH_SSM_PARAM=$(echo "${TF_OUTPUT}"   | jq -r '.ssh_key_ssm_parameter.value')

# Retrieve SSH private key from SSM Parameter Store into ~/.ssh/
SSH_KEY_PATH="${HOME}/.ssh/${CLUSTER_NAME}"
echo "Retrieving SSH private key from SSM Parameter Store (${SSH_SSM_PARAM})..."
aws ssm get-parameter \
  --name "${SSH_SSM_PARAM}" \
  --with-decryption \
  --query Parameter.Value \
  --output text > "${SSH_KEY_PATH}"
chmod 600 "${SSH_KEY_PATH}"
echo "SSH key saved to ${SSH_KEY_PATH}"

INVENTORY_FILE="${ANSIBLE_DIR}/inventory-${CLUSTER_NAME}.ini"

{
  echo "[k8s_manager]"
  echo "${CP_IDS}" | jq -r 'to_entries[] | .key' | while IFS= read -r key; do
    instance_id=$(echo "${CP_IDS}" | jq -r --arg k "${key}" '.[$k]')
    private_ip=$(echo "${CP_IPS}"  | jq -r --arg k "${key}" '.[$k]')
    echo "${CLUSTER_NAME}-cp-${key} ansible_host=${private_ip} instance_id=${instance_id}"
  done

  echo ""
  echo "[k8s_worker]"
  echo "${WORKER_IDS}" | jq -r 'to_entries[] | .key' | while IFS= read -r key; do
    instance_id=$(echo "${WORKER_IDS}" | jq -r --arg k "${key}" '.[$k]')
    private_ip=$(echo "${WORKER_IPS}"  | jq -r --arg k "${key}" '.[$k]')
    echo "${CLUSTER_NAME}-worker-${key} ansible_host=${private_ip} instance_id=${instance_id}"
  done

  echo ""
  echo "[k8s_cluster:children]"
  echo "k8s_manager"
  echo "k8s_worker"
  echo ""
  echo "[k8s_cluster:vars]"
  echo "ansible_user=ec2-user"
  echo "ansible_ssh_private_key_file=${SSH_KEY_PATH}"
  echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\"sh -c \\\"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p\\\"\"'"
  echo "k8s_api_endpoint=${API_ENDPOINT}"
  echo "cluster_name=${CLUSTER_NAME}"
} > "${INVENTORY_FILE}"

echo "Inventory written to ${INVENTORY_FILE}"
