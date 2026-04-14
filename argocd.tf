resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "6.7.11"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [module.eks]
}

resource "null_resource" "argocd_root_apps" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${module.eks.cluster_name} --region eu-west-1
      
      MAX_RETRIES=10
      RETRY_COUNT=0
      
      until kubectl get namespace argocd > /dev/null 2>&1; do
        if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
          echo "Timeout waiting for argocd namespace"
          exit 1
        fi
        echo "Waiting for argocd namespace..."
        sleep 10
        RETRY_COUNT=$((RETRY_COUNT+1))
      done
      
      kubectl apply -f https://raw.githubusercontent.com/App-of-apps-argo-example/gitops-core/main/applications/init/test.yaml
      kubectl apply -f https://raw.githubusercontent.com/App-of-apps-argo-example/gitops-core/main/applications/init/stage.yaml
      kubectl apply -f https://raw.githubusercontent.com/App-of-apps-argo-example/gitops-core/main/applications/init/prod.yaml
      
      cat <<CSS | kubectl apply -f -
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: aws-secretsmanager
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-west-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets
            namespace: external-secrets
CSS
    EOT
  }
}
