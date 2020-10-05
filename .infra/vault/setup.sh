#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAMESPACE='vault'
export CA_BUNDLE=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')

${DIR?}/cleanup.sh

if [[ -z ${AWS_ACCESS_KEY_ID_DEMO} ]]
then
    echo "Error: AWS_ACCESS_KEY_ID_DEMO env not set. Exiting.."
    exit 1
fi

if [[ -z ${AWS_SECRET_ACCESS_KEY_DEMO} ]]
then
    echo "Error: AWS_SECRET_ACCESS_KEY_DEMO env not set. Exiting.."
    exit 1
fi

if [[ -z ${REPO_OWNER} ]]
then
    echo "Error: REPO_OWNER env not set. Exiting.."
    exit 1
fi

if [[ -z ${GITHUB_USER} ]]
then
    echo "Error: GITHUB_USER env not set. Exiting.."
    exit 1
fi

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

kubectl create namespace vault
kubectl create namespace app

helm install tls-test --namespace=${NAMESPACE?} ${DIR?}/tls

kubectl get secret tls-test-client --namespace=${NAMESPACE?} --export -o yaml |\
  kubectl apply --namespace=app -f -

kubectl create secret generic demo-vault \
    --from-file ${DIR?}/configs/app-policy.hcl \
    --from-file ${DIR?}/configs/bootstrap.sh \
    --namespace=${NAMESPACE?}

kubectl create secret generic aws-creds \
    --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID_DEMO?} \
    --from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY_DEMO?} \
    --from-literal=REPO_OWNER=${REPO_OWNER?} \
    --from-literal=GITHUB_USER=${GITHUB_USER?} \
    --namespace=${NAMESPACE?}

kubectl label secret demo-vault app=vault-agent-demo \
    --namespace=${NAMESPACE?}

kubectl label secret aws-creds app=vault-agent-demo \
    --namespace=${NAMESPACE?}

helm install vault \
  --namespace="${NAMESPACE?}" \
  -f ${DIR?}/values.yaml hashicorp/vault --version=0.7.0
