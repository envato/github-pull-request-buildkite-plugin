#!/bin/bash

set -euo pipefail

function repo_from_origin() {
  local origin
  local without_prefix

  origin="$(git remote get-url origin)"
  without_prefix="${origin#*:}"
  echo "${without_prefix%.git}"
}
