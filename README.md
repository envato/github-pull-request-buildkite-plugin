# Github Pull Request Buildkite Plugin

![Build status](https://badge.buildkite.com/03e8876c9dbec4eb293aba87dc657e2dadf6afc6c0b9b761b4.svg)
[![MIT License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) that lets you
open Github pull requests.

## Example

The only required configuration is the pull request title. In this case the
pull request body will be empty, and the new pull request will propose merging
the current branch into `master`.

```yml
steps:
  - label: ":github: Open Pull Request"
    plugins:
      envato/github-pull-request#v0.1.0:
        title: "Example pull request title"
```

One can specify the branches to use. Here we open a pull request to merge the
`feature-1` branch into `staging`.

```yml
steps:
  - label: ":github: Open Pull Request"
    plugins:
      envato/github-pull-request#v0.1.0:
        title: "Deploy feature-1 to staging"
        head: "feature-1"
        base: "staging"
```

One can specify a cross account pull request also:

```yml
steps:
  - label: ":github: Open Pull Request"
    plugins:
      envato/github-pull-request#v0.1.0:
        title: "Please accept my cool feature"
        head: "my-account:my-branch"
        repo: "someone-elses-account/project"
```

To request reviews:

```yml
steps:
  - label: ":github: Open Pull Request"
    plugins:
      envato/github-pull-request#v0.1.0:
        title: "Example pull request title"
        reviewers:
          - toolmantim
          - keithpitt
        team-reviewers:
          - a_team
          - b_team
```

To add labels:

```yml
steps:
  - label: ":github: Open Pull Request"
    plugins:
      envato/github-pull-request#v0.1.0:
        title: "Example pull request title"
        labels:
          - wip
          - security
```

## Authentication

This plugin needs to authenticate with Github to open pull requests. To do so
it needs an API token. To provide this please store the token in the
`GITHUB_TOKEN` environment variable.

While this works, it's not recommended to commit unencrypted private tokens to
SCM.

```yml
steps:
  - label: ":github: Open Pull Request (not recommended)"
    plugins:
      envato/github-pull-request#v0.1.0:
        title: "Example pull request title"
    env:
      - GITHUB_TOKEN=<my-secret-token>
```

Instead, provide your secrets in via a secure mechanisim. Perhaps using the
[AWS S3 Secrets Buildkite Plugin](https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks#environment-variables).

## Configuration

### `title`

The title of the pull request.

### `body` (optional)

The contents of the pull request. Add some context and description of the
changes being proposed.

### `head` (optional)

The name of the branch where your changes are implemented. For cross-repository
pull requests in the same network, namespace head with a user like this:
`username:branch`.

Default: `BUILDKITE_BRANCH` (The current branch being built)

### `base` (optional)

The name of the branch you want the changes pulled into. This should be an
existing branch on the repository (see below).

Default: `master`

### `repo` (optional)

The repository on which the proposed changes will be pulled into. In the form
`owner/project`.

Default: The repository of the pipeline currently being built.

### `reviewers` (optional)

A list of users who will be requested to review the pull request. The reviewers
must be collaborators on the project.

### `team-reviewers` (optional)

A list of teams who will be requested to review the pull request. The teams
must be collaborators on the project.

### `labels` (optional)

A list of labels that will be added to the pull request.

## Development

To run the tests:

```sh
docker-compose run --rm tests
```

To run the [Buildkite Plugin
Linter](https://github.com/buildkite-plugins/buildkite-plugin-linter):

```sh
docker-compose run --rm lint
```
