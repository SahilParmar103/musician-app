#!/bin/bash

set -e

# Configure AWS CLI and kubeconfig
aws configure
aws eks update-kubeconfig --region "us-east-1" --name "musician-app-cluster"

echo
echo "Ensuring service access..."
echo "----------------------------"

# ArgoCD Access
if kubectl get ns argocd >/dev/null 2>&1; then
  argo_url=$(kubectl get svc -n argocd argocd-server -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null || echo "N/A")
  argo_user="admin"
  argo_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode 2>/dev/null || echo "N/A")
else
  argo_url="N/A"
  argo_user="admin"
  argo_password="N/A"
fi

# Prometheus and Grafana Access
if kubectl get ns prometheus >/dev/null 2>&1; then
  prometheus_url=$(kubectl get svc monitoring-kube-prometheus-prometheus -n prometheus -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null || echo "N/A")
  grafana_url=$(kubectl get svc monitoring-grafana -n prometheus -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null || echo "N/A")

  grafana_user="admin"
  grafana_password=$(kubectl get secret monitoring-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 --decode 2>/dev/null || echo "N/A")
else
  prometheus_url="N/A"
  grafana_url="N/A"
  grafana_user="admin"
  grafana_password="N/A"
fi

# Final Output
echo
echo "------------------------"
echo "ArgoCD URL: http://$argo_url"
echo "ArgoCD User: $argo_user"
echo "ArgoCD Initial Password: $argo_password"
echo
echo "Prometheus URL: http://$prometheus_url:9090"
echo
echo "Grafana URL: http://$grafana_url"
echo "Grafana User: $grafana_user"
echo "Grafana Password: $grafana_password"
echo "------------------------"
