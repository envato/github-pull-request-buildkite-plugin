#!/bin/bash

set -euo pipefail

function open_pull_request() {
  local title=$1
  local body=$2
  local head=$3
  local base=$4
  local repo=$5
  local payload
  local url

  payload=$(jq -n \
               --arg TITLE "${title}" \
               --arg BODY  "${body}" \
               --arg HEAD  "${head}" \
               --arg BASE  "${base}" \
               '{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }')
  url="$(base_url "${repo}")/pulls"
  github_post open_pull_request "${url}" "${payload}"
}

function request_reviews() {
  local reviewers=$1
  local team_reviewers=$2
  local pr_number=$3
  local repo=$4
  local payload
  local url

  payload=$(jq -n \
               --arg REVIEWERS      "${reviewers}" \
               --arg TEAM_REVIEWERS "${team_reviewers}" \
               '{ reviewers: $REVIEWERS | split("\n"), team_reviewers: $TEAM_REVIEWERS | split("\n") }')
  url="$(base_url "${repo}")/pulls/${pr_number}/requested_reviewers"
  github_post request_reviews "${url}" "${payload}"
}

function add_labels() {
  local labels=$1
  local pr_number=$2
  local repo=$3
  local payload
  local url

  payload=$(jq -n --arg LABELS "${labels}" '$LABELS | split("\n")')
  url="$(base_url "${repo}")/issues/${pr_number}/labels"
  github_post add_labels "${url}" "${payload}"
}

function base_url() {
  local repo=$1

  echo "https://api.github.com/repos/${repo}"
}

function github_post() {
  local name=$1
  local url=$2
  local payload=$3
  local temp_dir='tmp/github_api_calls'
  local request_file="${temp_dir}/${name}_request.json"
  local response_file="${temp_dir}/${name}_response.json"
  local http_code

  mkdir -p "${temp_dir}"
  echo "${payload}" > "${request_file}"

  http_code="$(curl --silent \
                    --write-out '%{http_code}'\
                    --data "${payload}" \
                    --header "Authorization: Bearer ${GITHUB_TOKEN}" \
                    --output "${response_file}" \
                    --request POST \
                    "${url}")"
  if [[ ! "${http_code}" =~ ^2[[:digit:]]{2}$ ]]; then
    echo "Github responded with ${http_code}:"
    cat "${response_file}"
    exit 1
  fi
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
