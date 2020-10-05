# Vault Action Demo

Demo for Vault Action using a self-hosted runner in Kubernetes.

## Prerequisites

Note: This project needs to be in a GitHub organization for Vault GitHub authentication.

The following repo secrets are required:

* `GH_TOKEN`: a personal access token with read.org privileges used to authenticate with Vault.
* `S3_BUCKET`: name of the S3 bucket where the binaries will be pushed.

### AWS

An S3 bucket needs to created. This is where the workflow will push the compiled
applications.

Additionally Vault needs to create IAM roles for users on demand. This requires a
user account to be created beforehand with the following:

* Programmatic access
* IAM policy attached to the user account,
  note the two places where specifics for your environment are required:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:AttachUserPolicy",
                "iam:CreateAccessKey",
                "iam:CreateUser",
                "iam:DeleteAccessKey",
                "iam:DeleteUser",
                "iam:DeleteUserPolicy",
                "iam:DetachUserPolicy",
                "iam:ListAccessKeys",
                "iam:ListAttachedUserPolicies",
                "iam:ListGroupsForUser",
                "iam:ListUserPolicies",
                "iam:PutUserPolicy",
                "iam:RemoveUserFromGroup"
            ],
            "Resource": [
                "arn:aws:iam::<ACCOUNT_ID>:user/<IAM USER NAME>"
            ]
        }
    ]
}
```

The following envs are required:

```bash
# Personal Access Token provided to the runner for
# this repo with `repo` privileges so the runner
# can register itself. Additionally we need your
# GH account name so we can create a Vault role
# for it.
export GITHUB_TOKEN='<TOKEN HERE>'
export GITHUB_USER='<YOUR USER ACCOUNT NAME>'

# This project is jasonodonnell/vault-action-demo,
# For example:
# REPO_OWNER is jasonodonnell
# REPO_NAME is vault-action-demo
export REPO_OWNER='<OWNER OF REPO>'
export REPO_NAME='<NAME OF REPO>'

# AWS creds that will be used by Vault to create IAM users.
export AWS_ACCESS_KEY_ID="<ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<SECRET_KEY>"

# S3 bucket name for IAM policy Vault will use for demo
export S3_BUCKET="<BUCKET_NAME>"
```

### Build Runner

```bash
cd .infra/runner/build
make build
```

This image either needs to be published to DockerHub, pushed
to the private registry for your cluster or use cloud builds
if your cluster supports it.

Note: make sure the runner is using the latest version. The runner
will try to auto-update itself but in containers that just results
in a crash loop.

### Deploy Runner

First, edit the `deployment.yaml` file with the appropriate image
name and tag you used above:

```bash
cd .infra/runner
vim deployment.yaml
```

Deploy the runner!
```
./setup.sh
```

### Deploy Vault

```bash
cd .infra/vault
./setup.sh
```

### Post Deploy Checkup

```bash
kubectl get pods -n vault
kubectl get pods -n runner
```

Additionally, in the GH Repo, check the runner is registered:
  `Settings>Actions>Self Hosted Runner`

## Run the Action!

```bash
git tag v1.0
git push origin --tags
```

An action should have been started in the Actions tab.
