module "env_vars_list" {
  source        = "../"
  env_file_path = "example.env"
}

module "cool_app_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.56.0"

  container_name           = "cool_app"
  container_image          = "some_crazy_app:latest"
  container_memory         = 512
  container_cpu            = 256
  essential                = "true"
  readonly_root_filesystem = "false"
  # ----------------------- HERE -----------------------
  environment = module.env_vars_list.env_list
  # ----------------------- HERE -----------------------

  # instead of
  /*environment = [
    {
      name  = "SOME_VAR_1"
      value = "value 123 44"
    },
    {
      name  = "SOME_VAR_2"
      value = "293n518c0xm183ycn1x09"
    }
  ]*/
}

module "cool_app2_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.56.0"

  container_name           = "cool_app2"
  container_image          = "some_crazy_app:latest"
  container_memory         = 512
  container_cpu            = 256
  essential                = "true"
  readonly_root_filesystem = "false"
  # ----------------------- HERE -----------------------
  environment = concat(
    [
      {
        name  = "SOME_VAR_1"
        value = kubernetes_deployment.example.id
      },
      {
        name  = "SOME_VAR_2"
        value = kubernetes_deployment.example.metadata.name
      }
    ],
    module.env_vars_list.env_list
  )
  # ----------------------- HERE -----------------------
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "terraform-example"
    labels = {
      test = "MyExampleApp"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          # ----------------------- HERE -----------------------
          dynamic "env" {
            for_each = module.env_vars_list.env_list
            iterator = i
            content {
              name  = i.value["name"]
              value = i.value["value"]
            }
          }
          # ----------------------- HERE -----------------------

          liveness_probe {
            http_get {
              path = "/nginx_status"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}