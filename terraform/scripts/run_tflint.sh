#!/bin/bash
# Runs tflint recursively over terraform/ with an absolute path to .tflint.hcl.
# Required because tflint --recursive resolves --config relative to each
# subdirectory it descends into, so a relative path breaks for nested modules.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

exec tflint \
  --config="${REPO_ROOT}/.tflint.hcl" \
  --recursive \
  --chdir="${REPO_ROOT}/terraform"
