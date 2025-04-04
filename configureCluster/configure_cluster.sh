#!/bin/bash

secrets_path="./secrets" # base path for secrets

harbor_ca="harbor-ca-cert"
harbor_ca_path="./harbor.crt"

redis_credentials="redis-credentials"
redis_password_path="$secrets_path/redis/password"
redis_helm_name="zolara-redis"
redis_helm_path="./redis/redis.yaml"

echo "----------------------------------"
echo "Add necessary helm repositories"
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "----------------------------------"
echo "Copy harbor certificate"
kubectl create configmap $harbor_ca --from-file=ca.crt=$harbor_ca_path -n kube-system --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f kube-daemonset.yaml

echo "----------------------------------"
echo "Create namespaces"
kubectl apply -f ./namespaces.yaml

echo "In namespace app"
kubectl create secret generic $redis_credentials --from-file=redis-password=$redis_password_path -n app --dry-run=client -oyaml | kubectl apply -f -

echo "In namespace redis"
kubectl create secret generic $redis_credentials --from-file=redis-password=$redis_password_path -n redis --dry-run=client -oyaml | kubectl apply -f -