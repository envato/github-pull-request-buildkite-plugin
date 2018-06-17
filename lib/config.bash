#!/bin/bash

set -euo pipefail

function plugin_read_config() {
  local var="BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_$1"
  local default="${2:-}"
  echo "${!var:-$default}"
}

function plugin_read_list() {
  local prefix="BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_$1"
  local parameter="${prefix}_0"

  if [[ -n "${!parameter:-}" ]]; then
    local i=0
    local parameter="${prefix}_${i}"
    while [[ -n "${!parameter:-}" ]]; do
      echo "${!parameter}"
      i=$((i+1))
      parameter="${prefix}_${i}"
    done
  elif [[ -n "${!prefix:-}" ]]; then
    echo "${!prefix}"
  fi
}
