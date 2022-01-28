module "cert-manager" {
  source                                 = "terraform-iaac/cert-manager/kubernetes"
  version                                = "2.2.2"
  cluster_issuer_email                   = "gzamboni@gmail.com"
  cluster_issuer_name                    = "letsencrypt"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
}
