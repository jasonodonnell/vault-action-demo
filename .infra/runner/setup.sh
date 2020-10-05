#!/bin/bash

export REPO_OWNER='jasonodonnell'
export REPO_NAME='vault-action-demo'

if [[ -z ${GITHUB_TOKEN} ]]
then
    echo "GITHUB_TOKEN env not set. Exiting.."
    exit 1
fi

kubectl create namespace runner
kubectl create serviceaccount runner-sa -n runner

kubectl create secret generic runner-k8s-secret -n runner \
    --from-literal=GITHUB_TOKEN=${GITHUB_TOKEN?} \
    --from-literal=REPO_NAME=${REPO_NAME?} \
    --from-literal=REPO_OWNER=${REPO_OWNER?}

kubectl create -f deployment.yaml -n runner
