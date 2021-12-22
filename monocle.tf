resource "kubernetes_namespace" "monocle" {
  metadata {
    labels = {
      app = "monocle-gateway"
    }

    name = "monocle"
  }
}

resource "kubernetes_secret" "monocle-token" {
  metadata {
    name      = "monocle-token-file"
    namespace = kubernetes_namespace.monocle.metadata.0.name
    labels = {
      app = kubernetes_namespace.monocle.metadata.0.labels.app
    }
  }

  data = {
    "monocle.token"      = "${file("${path.module}/files/credentials/monocle.token")}"
    "monocle.properties" = "${file("${path.module}/files/monocle/monocle.properties")}"
  }
}

resource "kubernetes_deployment" "monocle_gateway" {
  metadata {
    name      = "monocle-gateway"
    namespace = kubernetes_namespace.monocle.metadata.0.name
    labels = {
      app = kubernetes_namespace.monocle.metadata.0.labels.app
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = kubernetes_namespace.monocle.metadata.0.labels.app
      }
    }

    template {
      metadata {
        labels = {
          app = kubernetes_namespace.monocle.metadata.0.labels.app
        }
      }

      spec {
        node_selector = {
          "kubernetes.io/hostname" = "zberry"
        }

        container {
          image = "monoclecam/monocle-gateway:latest"
          name  = "monocle-gateway"

          volume_mount {
            name       = "monocle-token"
            mount_path = "/etc/monocle"
          }

          readiness_probe {
            tcp_socket {
              port = 443
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          liveness_probe {
            tcp_socket {
              port = 443
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        volume {
          name = "monocle-token"
          secret {
            secret_name = kubernetes_secret.monocle-token.metadata.0.name
            items {
              key  = "monocle.token"
              path = "monocle.token"
            }
            items {
              key  = "monocle.properties"
              path = "monocle.properties"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "monocle_gateway" {
  metadata {
    name      = "monocle-gateway"
    namespace = kubernetes_namespace.monocle.metadata.0.name

    labels = {
      app = kubernetes_namespace.monocle.metadata.0.labels.app
    }

    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/path"   = "/"
      "prometheus.io/port"   = "443"
    }
  }
  spec {
    selector = {
      app = kubernetes_namespace.monocle.metadata.0.labels.app
    }


    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = 443
    }
    port {
      name        = "rtsp"
      protocol    = "TCP"
      port        = 8555
      target_port = 8555
    }
    port {
      name        = "gateway"
      protocol    = "TCP"
      port        = 8554
      target_port = 8554
    }
  }
}

resource "kubernetes_ingress" "monocle_gateway" {
  metadata {
    name      = "monocle-gateway"
    namespace = kubernetes_namespace.monocle.metadata.0.name

    annotations = {
      "kubernetes.io/ingress.class"    = "traefik"
      "cert-manager.io/cluster-issuer" = module.cert-manager.cluster_issuer_name
    }
  }
  spec {
    rule {
      host = "192.168.0.11.sslip.io"
      http {
        path {
          backend {
            service_name = kubernetes_service.monocle_gateway.metadata.0.name
            service_port = 443
          }
        }
      }
    }
  }
}
