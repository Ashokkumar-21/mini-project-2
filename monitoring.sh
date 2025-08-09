#!/bin/bash
set -e


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


kubectl create namespace monitoring || true


helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer
