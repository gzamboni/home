
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
  host        = "https://${var.master_ip}:6443"
}

provider "kubectl" {
  config_path = var.kubeconfig
  host        = "https://${var.master_ip}:6443"
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
    host        = "https://${var.master_ip}:6443"
  }
}

