
terraform {
  backend "remote" {
    organization = "gzamboni"

    workspaces {
      name = "home"
    }
  }
}
