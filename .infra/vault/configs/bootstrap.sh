#!/bin/sh

OUTPUT=/tmp/output.txt
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_SKIP_VERIFY=true

vault operator init -n 1 -t 1 >> ${OUTPUT?}

unseal=$(cat ${OUTPUT?} | grep "Unseal Key 1:" | sed -e "s/Unseal Key 1: //g")
root=$(cat ${OUTPUT?} | grep "Initial Root Token:" | sed -e "s/Initial Root Token: //g")

vault operator unseal ${unseal?}
echo "${root?}" > /tmp/root

vault login -no-print ${root?}

# Add 'app' policy for each demo
vault policy write app /vault/userconfig/demo-vault/app-policy.hcl

# GitHub Auth
vault auth enable github
vault write auth/github/config organization=${REPO_OWNER?}
vault write auth/github/map/users/${GITHUB_USER?} value=app

# Demo 1: Static Secrets
vault secrets enable -path=secret/ kv
vault kv put secret/hashiconf hashiconf=rocks

# Demo 2: AWS
vault secrets enable aws
vault write aws/config/root \
    access_key=${AWS_ACCESS_KEY_ID?} \
    secret_key=${AWS_SECRET_ACCESS_KEY?} \
    region=us-west-2

vault write aws/config/lease \
    lease="5m" \
    lease_max="10m"

vault write aws/roles/s3 policy=-<<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket"
         ],
         "Resource":"arn:aws:s3:::vault-action-demo"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject",
            "s3:GetObject"
         ],
         "Resource":"arn:aws:s3:::vault-action-demo/*"
      }
   ]
}
EOF
