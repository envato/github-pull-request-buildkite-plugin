#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following to get more detail on failures of stubs
# export JQ_STUB_DEBUG=/dev/tty
# export CURL_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty
# export CAT_STUB_DEBUG=/dev/tty

@test 'Opens the Github pull request' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export GITHUB_TOKEN=secret-github-token

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD feature-branch --arg BASE master "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url'
  stub curl '-s -X POST https://api.github.com/repos/owner/project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat 'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response'

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
  unstub curl
  unstub git
}

@test 'Opens the Github pull request on specified repository' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_REPO=another-owner/another-project
  export GITHUB_TOKEN=secret-github-token

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD feature-branch --arg BASE master "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url'
  stub curl '-s -X POST https://api.github.com/repos/another-owner/another-project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat 'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response'

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
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

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD pr-head --arg BASE pr-base "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url'
  stub curl '-s -X POST https://api.github.com/repos/owner/project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat 'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response'

  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and requests reviews from one user' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_REVIEWERS=pr-reviewer
  export GITHUB_TOKEN=secret-github-token

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD feature-branch --arg BASE master "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url' \
    '-n --arg REVIEWERS "pr-reviewer" --arg TEAM_REVIEWERS "" "{ reviewers: $REVIEWERS | split(\"\n\"), team_reviewers: $TEAM_REVIEWERS | split(\"\n\") }" : echo json-request-reviews-request'
  stub curl \
    '-s -X POST https://api.github.com/repos/owner/project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes' \
    '-s -X POST https://api.github.com/repos/owner/project/pulls/711/requested_reviewers -d json-request-reviews-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/request_reviews_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat \
    'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response' \
    'tmp/github_api_calls/request_reviews_response.json : echo json-request-reviews-response'


  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
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

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD feature-branch --arg BASE master "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url' \
    '-n --arg REVIEWERS "pr-reviewer1\npr-reviewer2" --arg TEAM_REVIEWERS "" "{ reviewers: $REVIEWERS | split(\"\n\"), team_reviewers: $TEAM_REVIEWERS | split(\"\n\") }" : echo json-request-reviews-request'
  stub curl \
    '-s -X POST https://api.github.com/repos/owner/project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes' \
    '-s -X POST https://api.github.com/repos/owner/project/pulls/711/requested_reviewers -d json-request-reviews-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/request_reviews_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat \
    'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response' \
    'tmp/github_api_calls/request_reviews_response.json : echo json-request-reviews-response'


  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and requests reviews from one team' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TEAM_REVIEWERS=pr-reviewer
  export GITHUB_TOKEN=secret-github-token

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD feature-branch --arg BASE master "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url' \
    '-n --arg REVIEWERS "" --arg TEAM_REVIEWERS "pr-reviewer" "{ reviewers: $REVIEWERS | split(\"\n\"), team_reviewers: $TEAM_REVIEWERS | split(\"\n\") }" : echo json-request-reviews-request'
  stub curl \
    '-s -X POST https://api.github.com/repos/owner/project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes' \
    '-s -X POST https://api.github.com/repos/owner/project/pulls/711/requested_reviewers -d json-request-reviews-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/request_reviews_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat \
    'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response' \
    'tmp/github_api_calls/request_reviews_response.json : echo json-request-reviews-response'


  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and requests reviews from two teams' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TEAM_REVIEWERS_0=pr-reviewer1
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TEAM_REVIEWERS_1=pr-reviewer2
  export GITHUB_TOKEN=secret-github-token

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD feature-branch --arg BASE master "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url' \
    '-n --arg REVIEWERS "" --arg TEAM_REVIEWERS "pr-reviewer1\npr-reviewer2" "{ reviewers: $REVIEWERS | split(\"\n\"), team_reviewers: $TEAM_REVIEWERS | split(\"\n\") }" : echo json-request-reviews-request'
  stub curl \
    '-s -X POST https://api.github.com/repos/owner/project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes' \
    '-s -X POST https://api.github.com/repos/owner/project/pulls/711/requested_reviewers -d json-request-reviews-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/request_reviews_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat \
    'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response' \
    'tmp/github_api_calls/request_reviews_response.json : echo json-request-reviews-response'


  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
  unstub curl
  unstub git
}

@test 'Opens the Github pull request and adds a label' {
  export BUILDKITE_BRANCH=feature-branch
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_TITLE=pr-title
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_BODY=pr-body
  export BUILDKITE_PLUGIN_GITHUB_PULL_REQUEST_LABELS=pr-label
  export GITHUB_TOKEN=secret-github-token

  stub jq \
    '-n --arg TITLE pr-title --arg BODY pr-body --arg HEAD feature-branch --arg BASE master "{ title: $TITLE, body: $BODY, head: $HEAD, base: $BASE }" : echo json-open-pr-request' \
    '.number : echo 711' \
    '.html_url : echo pr-url' \
    '-n --arg LABELS "pr-label" "$LABELS | split(\"\n\")" : echo json-add-labels-request'
  stub curl \
    '-s -X POST https://api.github.com/repos/owner/project/pulls -d json-open-pr-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/open_pull_request_response.json : echo yes' \
    '-s -X POST https://api.github.com/repos/owner/project/issues/711/labels -d json-add-labels-request -H "Authorization: Bearer secret-github-token" -o tmp/github_api_calls/add_labels_response.json : echo yes'
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub cat \
    'tmp/github_api_calls/open_pull_request_response.json : echo json-open-pr-response' \
    'tmp/github_api_calls/add_labels_response.json : echo json-add-labels-response'


  run $PWD/hooks/command

  assert_success
  assert_output --partial 'Github pull request opened: pr-url'
  unstub jq
  unstub curl
  unstub git
}

