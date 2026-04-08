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

resource "null_resource" "argocd_root_app" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${module.eks.cluster_name} --region eu-central-1
      kubectl apply -f https://raw.githubusercontent.com/App-of-apps-argo-example/gitops-core/main/applications/init/root-app.yaml
    EOT
  }
}
