#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment the following to get more detail on failures of stubs
# export CURL_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test 'Opens the Github pull request' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export GITHUB_TOKEN=secret-github-token

  stub curl "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  unstub curl
  unstub git
}

@test 'Records the opened Github pull request number in build metadata and adds an annotation' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export GITHUB_TOKEN=secret-github-token

  stub curl "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent \
    'meta-data set github-pull-request-plugin-number 42 : echo metadata set' \
    'annotate ":github: Github pull request [#42](https://github.com/owner/project/pull/42) opened." --style info : echo annotated'

  run $PWD/hooks/command

  assert_success
  unstub buildkite-agent
  unstub git
}

@test 'Opens the Github pull request on specified repository' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_REPO=another-owner/another-project
  export GITHUB_TOKEN=secret-github-token

  stub curl "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/another-owner/another-project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/another-owner/another-project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/another-owner/another-project/pull/42'
  unstub curl
  unstub git
}

@test 'Opens the Github pull request using specified head and base' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_HEAD=pr-head
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BASE=pr-base
  export GITHUB_TOKEN=secret-github-token

  stub curl "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"pr-head\",\"base\":\"pr-base\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and requests reviews from one user' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_REVIEWERS=pr-reviewer
  export GITHUB_TOKEN=secret-github-token

  stub curl \
    "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200" \
    "--silent --write-out '%{http_code}' --data '{\"reviewers\":[\"pr-reviewer\"],\"team_reviewers\":[]}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/request_reviews_response.json --request POST https://api.github.com/repos/owner/project/pulls/42/requested_reviewers : echo '{}' > tmp/github_api_calls/request_reviews_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  assert_output --partial 'Reviews requested'
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and requests reviews from two users' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_REVIEWERS_0=pr-reviewer1
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_REVIEWERS_1=pr-reviewer2
  export GITHUB_TOKEN=secret-github-token

  stub curl \
    "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200" \
    "--silent --write-out '%{http_code}' --data '{\"reviewers\":[\"pr-reviewer1\",\"pr-reviewer2\"],\"team_reviewers\":[]}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/request_reviews_response.json --request POST https://api.github.com/repos/owner/project/pulls/42/requested_reviewers : echo '{}' > tmp/github_api_calls/request_reviews_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  assert_output --partial 'Reviews requested'
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and requests reviews from one team' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TEAM_REVIEWERS=pr-reviewer-team
  export GITHUB_TOKEN=secret-github-token

  stub curl \
    "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200" \
    "--silent --write-out '%{http_code}' --data '{\"reviewers\":[],\"team_reviewers\":[\"pr-reviewer-team\"]}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/request_reviews_response.json --request POST https://api.github.com/repos/owner/project/pulls/42/requested_reviewers : echo '{}' > tmp/github_api_calls/request_reviews_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  assert_output --partial 'Reviews requested'
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and requests reviews from two teams' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TEAM_REVIEWERS_0=pr-reviewer-team1
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TEAM_REVIEWERS_1=pr-reviewer-team2
  export GITHUB_TOKEN=secret-github-token

  stub curl \
    "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200" \
    "--silent --write-out '%{http_code}' --data '{\"reviewers\":[],\"team_reviewers\":[\"pr-reviewer-team1\",\"pr-reviewer-team2\"]}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/request_reviews_response.json --request POST https://api.github.com/repos/owner/project/pulls/42/requested_reviewers : echo '{}' > tmp/github_api_calls/request_reviews_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  assert_output --partial 'Reviews requested'
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and adds a label' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_LABELS=pr-label
  export GITHUB_TOKEN=secret-github-token

  stub curl \
    "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200" \
    "--silent --write-out '%{http_code}' --data '[\"pr-label\"]' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/add_labels_response.json --request POST https://api.github.com/repos/owner/project/issues/42/labels : echo '{}' > tmp/github_api_calls/add_labels_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  assert_output --partial 'Labels added'
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and adds two labels' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_LABELS_0=pr-label1
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_LABELS_1=pr-label2
  export GITHUB_TOKEN=secret-github-token

  stub curl \
    "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo '{\"number\":42,\"html_url\":\"https://github.com/owner/project/pull/42\"}' > tmp/github_api_calls/open_pull_request_response.json && echo 200" \
    "--silent --write-out '%{http_code}' --data '[\"pr-label1\",\"pr-label2\"]' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/add_labels_response.json --request POST https://api.github.com/repos/owner/project/issues/42/labels : echo '{}' > tmp/github_api_calls/add_labels_response.json && echo 200"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: https://github.com/owner/project/pull/42'
  assert_output --partial 'Labels added'
  unstub curl
  unstub git
}

@test 'Errors out if Github return non-200 HTTP status' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export GITHUB_TOKEN=secret-github-token

  stub curl "--silent --write-out '%{http_code}' --data '{\"title\":\"pr-title\",\"body\":\"pr-body\",\"head\":\"feature-branch\",\"base\":\"main\"}' --header 'Authorization: Bearer secret-github-token' --output tmp/github_api_calls/open_pull_request_response.json --request POST https://api.github.com/repos/owner/project/pulls : echo 'The error message from Github' > tmp/github_api_calls/open_pull_request_response.json && echo 512"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent

  run $PWD/hooks/command

  assert_failure
  assert_output --partial 'Github responded with 512:'
  assert_output --partial 'error message from Github'
  unstub curl
  unstub git
}

@test 'Errors out if GITHUB_TOKEN is not provided' {
  run $PWD/hooks/command

  assert_failure
  assert_output --partial 'Error: GITHUB_TOKEN environment variable not set'
}
