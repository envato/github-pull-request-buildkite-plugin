#!/bin/bash

set -euo pipefail

function open_pull_request() {
  local title=$1
  local body=$2
  local head=$3
  local base=$4
  local repo=$5

  local payload=$(jq -n \
                     --arg TITLE "${title}" \
                     --arg BODY  "${body}" \
                     --arg HEAD  "${head}" \
                     --arg BASE  "${base}" \
                     '{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }')
  local url="$(base_url "${repo}")/pulls"
  echo $(github_post open_pull_request "${url}" "${payload}")
}

function request_reviews() {
  local reviewers=$1
  local team_reviewers=$2
  local pr_number=$3
  local repo=$4

  local payload=$(jq -n \
                     --arg REVIEWERS      "${reviewers}" \
                     --arg TEAM_REVIEWERS "${team_reviewers}" \
                     '{ reviewers: $REVIEWERS | split("\n"), team_reviewers: $TEAM_REVIEWERS | split("\n") }')
  local url="$(base_url "${repo}")/pulls/${pr_number}/requested_reviewers"
  echo $(github_post request_reviews "${url}" "${payload}")
}

function add_labels() {
  local labels=$1
  local pr_number=$2
  local repo=$3

  local payload=$(jq -n --arg LABELS "${labels}" '$LABELS | split("\n")')
  local url="$(base_url "${repo}")/issues/${pr_number}/labels"
  echo $(github_post add_labels "${url}" "${payload}")
}

function repo_from_origin() {
  local origin=$(git remote get-url origin)
  local without_prefix=${origin#*:}
  echo ${without_prefix%.git}
}

function base_url() {
  local repo=$1

  echo "https://api.github.com/repos/${repo}"
}

function github_post() {
  local name=$1
  local url=$2
  local payload=$3

  mkdir -p tmp/github_api_calls
  echo "${payload}" > "tmp/github_api_calls/${name}_request.json"
  curl -s \
       -X POST "${url}" \
       -d "${payload}" \
       -H "Authorization: Bearer ${GITHUB_TOKEN}" \
       -o "tmp/github_api_calls/${name}_response.json"
  echo "$(cat tmp/github_api_calls/${name}_response.json)"
}

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
