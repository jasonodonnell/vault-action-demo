#!/bin/bash

kubectl delete deployment -n runner runner-deployment
kubectl delete secret -n runner runner-k8s-secret
kubectl delete serviceaccount -n runner runner-sa
kubectl delete namespace runner
