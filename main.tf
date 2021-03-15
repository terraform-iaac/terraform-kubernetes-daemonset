resource "kubernetes_daemonset" "this" {

  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    min_ready_seconds = var.min_ready_seconds

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }


      spec {
        restart_policy = var.restart_policy

        service_account_name            = var.service_account_name
        automount_service_account_token = var.service_account_token

        dynamic "volume" {
          for_each = var.volume_empty_dir
          content {
            empty_dir {}
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_nfs
          content {
            nfs {
              path   = volume.value.path_on_nfs
              server = volume.value.nfs_endpoint
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_host_path
          content {
            host_path {
              path = volume.value.path_on_node
              type = lookup(volume.value, "type", null)
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_config_map
          content {
            config_map {
              default_mode = volume.value.mode
              name         = volume.value.name
            }
            name = volume.value.volume_name
          }
        }



        dynamic "volume" {
          for_each = var.volume_gce_disk
          content {
            gce_persistent_disk {
              pd_name   = volume.value.gce_disk
              fs_type   = lookup(volume.value, "fs_type", null)
              partition = lookup(volume.value, "partition", null)
              read_only = lookup(volume.value, "read_only", null)
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_secret
          content {
            secret {
              secret_name  = volume.value.secret_name
              default_mode = lookup(volume.value, "default_mode", null)
              optional     = lookup(volume.value, "optional", null)
              dynamic "items" {
                for_each = lookup(volume.value, "items", [])
                content {
                  key  = items.value.key
                  path = items.value.path
                  mode = lookup(items.value, "mode", null)
                }
              }
            }
            name = volume.value.volume_name
          }
        }

        dynamic "volume" {
          for_each = var.volume_aws_disk
          content {
            aws_elastic_block_store {
              fs_type   = lookup(volume.value, "fs_type", null)
              partition = lookup(volume.value, "partition", null)
              read_only = lookup(volume.value, "read_only", null)
              volume_id = volume.value.volume_id
            }
            name = volume.value.volume_name
          }
        }

        dynamic "host_aliases" {
          iterator = hosts
          for_each = var.hosts
          content {
            hostnames = hosts.value.hostname
            ip        = hosts.value.ip
          }
        }

        dynamic "security_context" {
          for_each = var.security_context
          content {
            fs_group        = lookup(security_context.value, "fs_group", null)
            run_as_group    = lookup(security_context.value, "run_as_group", null)
            run_as_user     = lookup(security_context.value, "run_as_user", null)
            run_as_non_root = lookup(security_context.value, "run_as_non_root", null)
          }
        }

        container {
          name              = var.name
          image             = var.image
          args              = var.args
          command           = var.command
          image_pull_policy = var.image_pull_policy
          tty               = var.tty

          dynamic "security_context" {
            for_each = var.security_context
            content {
              read_only_root_filesystem = lookup(security_context.value, "read_only_root_filesystem", null)
            }
          }

          dynamic "env" {
            for_each = var.env_field
            content {
              name = env.value.name
              value_from {
                field_ref {
                  field_path = env.value.field_path
                }
              }
            }
          }

          dynamic "env" {
            for_each = var.env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          dynamic "env" {
            for_each = var.env_secret
            content {
              name = env.value.name
              value_from {
                secret_key_ref {
                  name = env.value.secret_name
                  key  = env.value.secret_key
                }
              }
            }
          }

          dynamic "resources" {
            for_each = var.resources
            content {
              dynamic "requests" {
                for_each = lookup(resources.value, "request_cpu", false) == false ? lookup(resources.value, "request_memory", false) == false ? [] : var.resources : var.resources
                content {
                  cpu    = lookup(resources.value, "request_cpu", null)
                  memory = lookup(resources.value, "request_memory", null)
                }
              }
              dynamic "limits" {
                for_each = lookup(resources.value, "limit_cpu", false) == false ? lookup(resources.value, "limit_memory", false) == false ? [] : var.resources : var.resources
                content {
                  cpu    = lookup(resources.value, "limit_cpu", null)
                  memory = lookup(resources.value, "limit_memory", null)
                }
              }
            }
          }

          dynamic "port" {
            for_each = var.internal_port
            content {
              container_port = port.value.internal_port
              name           = substr(port.value.name, 0, 14)
              host_port      = lookup(port.value, "host_port", null)
            }
          }

          dynamic "volume_mount" {
            for_each = var.volume_mount
            content {
              mount_path = volume_mount.value.mount_path
              sub_path   = lookup(volume_mount.value, "sub_path", null)
              name       = volume_mount.value.volume_name
              read_only  = lookup(volume_mount.value, "read_only", false)
            }
          }

          dynamic "liveness_probe" {
            for_each = var.liveness_probe
            content {
              failure_threshold     = lookup(liveness_probe.value, "failure_threshold", null)
              initial_delay_seconds = lookup(liveness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(liveness_probe.value, "period_seconds", null)
              success_threshold     = lookup(liveness_probe.value, "success_threshold", null)
              timeout_seconds       = lookup(liveness_probe.value, "timeout_seconds", null)
              dynamic "http_get" {
                for_each = lookup(liveness_probe.value, "http_get", [])
                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = lookup(http_get.value, "header_name", [])
                    content {
                      name  = lookup(http_get.value, "header_name", null)
                      value = lookup(http_get.value, "header_value", null)
                    }
                  }
                }
              }
              dynamic "tcp_socket" {
                for_each = lookup(liveness_probe.value, "tcp_socket", null) == null ? [] : [{}]
                content {
                  port = liveness_probe.value.tcp_socket_port
                }
              }
            }
          }

          dynamic "readiness_probe" {
            for_each = var.readiness_probe
            content {
              failure_threshold     = lookup(readiness_probe.value, "failure_threshold", null)
              initial_delay_seconds = lookup(readiness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(readiness_probe.value, "period_seconds", null)
              success_threshold     = lookup(readiness_probe.value, "success_threshold", null)
              timeout_seconds       = lookup(readiness_probe.value, "timeout_seconds", null)
              dynamic "http_get" {
                for_each = lookup(readiness_probe.value, "http_get", [])
                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = lookup(http_get.value, "header_name", [])
                    content {
                      name  = lookup(http_get.value, "header_name", null)
                      value = lookup(http_get.value, "header_value", null)
                    }
                  }
                }
              }
              dynamic "tcp_socket" {
                for_each = lookup(readiness_probe.value, "tcp_socket", null) == null ? [] : [{}]
                content {
                  port = readiness_probe.value.tcp_socket_port
                }
              }
            }
          }

          dynamic "lifecycle" {
            for_each = var.lifecycle_events
            content {
              dynamic "pre_stop" {
                for_each = lookup(lifecycle.value, "pre_stop", [])
                content {
                  exec {
                    command = lookup(pre_stop.value, "exec_command", null)
                  }
                  dynamic "http_get" {
                    for_each = lookup(pre_stop.value, "http_get", [])
                    content {
                      path   = lookup(http_get.value, "path", null)
                      port   = lookup(http_get.value, "port", null)
                      scheme = lookup(http_get.value, "scheme", null)
                      host   = lookup(http_get.value, "host", null)

                      dynamic "http_header" {
                        for_each = lookup(http_get.value, "header_name", [])
                        content {
                          name  = lookup(http_get.value, "header_name", null)
                          value = lookup(http_get.value, "header_value", null)
                        }
                      }
                    }
                  }
                  dynamic "tcp_socket" {
                    for_each = lookup(lifecycle.value, "tcp_socket", null) == null ? [] : [{}]
                    content {
                      port = lifecycle.value.tcp_socket_port
                    }
                  }
                }
              }
              dynamic "post_start" {
                for_each = lookup(lifecycle.value, "post_start", [])
                content {
                  exec {
                    command = lookup(post_start.value, "exec_command", null)
                  }
                  dynamic "http_get" {
                    for_each = lookup(post_start.value, "http_get", [])
                    content {
                      path   = lookup(http_get.value, "path", null)
                      port   = lookup(http_get.value, "port", null)
                      scheme = lookup(http_get.value, "scheme", null)
                      host   = lookup(http_get.value, "host", null)

                      dynamic "http_header" {
                        for_each = lookup(http_get.value, "header_name", [])
                        content {
                          name  = lookup(http_get.value, "header_name", null)
                          value = lookup(http_get.value, "header_value", null)
                        }
                      }
                    }
                  }
                  dynamic "tcp_socket" {
                    for_each = lookup(lifecycle.value, "tcp_socket", null) == null ? [] : [{}]
                    content {
                      port = lifecycle.value.tcp_socket_port
                    }
                  }
                }
              }
            }
          }

        }
      }
    }
  }
}