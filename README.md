Terraform module for Kubernetes Statefulset
==========================================

Terraform module used to easily create a daemonset with singe container. With simple syntax.

## Usage

```terraform
module "daemonset" {
  source        = "../"
  name          = "mariadb"
  namespace     = "db"
  image         = "mariabdb:latest"
  internal_port = [
    {
      name          = "db"
      internal_port = "3306"
    }
  ]
}
```

## Terraform Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.26 |
| kubernetes | >= 2.0.1 |

## Inputs

| Name | Description | Type | Default | Example | Required |
|------|-------------|------|---------|---------|:--------:|
| name  | Name of the daemonset | `string` | n/a | `application` | yes |
| namespace | Namespace in which create the daemonset | `string` | `default` | `default` | no |
| custom\_labels | Add custom label to pods | `object` | `{ app = var.name }` | `{ mylabel = "apps" }` | no |
| image | Docker image name | `string` | n/a | `ubuntu:18.04` | yes |
| image\_pull_policy | One of Always, Never, IfNotPresent | `string` | `IfNotPresent` | `Always` | no |
| args | Arguments to the entrypoint | `list(string)` | n/a | `["--dev", "--nodaemon"]` | no |
| command | Change entrypoint array | `list(string)` | n/a | `["/bin/bash", "-c", "pwd"]` | no |
| service_account\_name | Is the name of the ServiceAccount to use to run this pod | `string` | `null` | `application-sa` | no |
| service_accoun_token | Indicates whether a service account token should be automatically mounted | `bool` | `null` | `true` | no |
| restart\_policy | Restart policy for all containers within the pod. One of Always, OnFailure, Never | `string` | `Always` | `OnFailure` | no |
| env | Name and value pairs to set in the container's environment | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    name  = "PORT"<br>    value = "80"<br>  },<br>  {<br>    name  = "ADDRESS"<br>    value = "0.0.0.0"<br>  }<br>]</pre> | no |
| env\_field | Get field from k8s and add as environment variables to pods | <pre>list(object({<br>    name       = string<br>    field_path = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    name       = "NODE-NAME"<br>    field_path = "spec.nodeName"<br>  }<br>]</pre> | no |
| env\_secret | Get secret keys from k8s and add as environment variables to pods | <pre>list(object({<br>    name        = string<br>    secret_name = string<br>    secret_key  = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    name        = "DbPass"<br>    secret_name = "db-credentials"<br>    secret_key  = "password"<br>  }<br>]</pre> | no |
| resources | Compute Resources required by this container. CPU/RAM requests/limits | <pre>object({<br>    request_cpu    = string - (Optional)<br>    request_memory = string - (Optional)<br>    limit_cpu      = string - (Optional)<br>    limit_memory   = string - (Optional)<br>  })</pre> | n/a | <pre>{<br>    request_cpu    = "100m"<br>    request_memory = "800Mi"<br>    limit_cpu      = "120m"<br>    limit_memory   = "900Mi"<br>}</pre> | no || internal\_port | List of ports to expose from the container | <pre>list(object({<br>    internal_port = number<br>    name          = string<br>    host_port     = number - (Optional)<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    internal_port = 8080<br>    name          = web<br>    host_port     = 80 - (Optional)<br>  }<br>]</pre> | no |
| hosts | Add /etc/hosts records to pods | <pre>list(object({<br>    hostname       = string<br>    ip             = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    hostname       = "mysite.com"<br>    ip             = "10.10.1.20"<br>  }<br>]</pre> | no |
| volume\_mount | Mount path from pods to volume | <pre>list(object({<br>    mount_path  = string<br>    volume_name = string<br>    sub_path    = string - (Optional)<br>    read_only   = bool   - (Optional)<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    mount_path  = "/mnt"<br>    volume_name = "node"<br>    sub_path    = "app"<br>    read_only   = false<br>  }<br>]</pre> | no |
| volume\_nfs | Represents an NFS mounts on the host | <pre>list(object({<br>    path_on_nfs  = string<br>    nfs_endpoint = string<br>    volume_name  = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    path_on_nfs    = "/"<br>    nfs_endpoint   = "10.10.0.100"<br>    volume_name    = "share"<br>  }<br>]</pre> | no |
| volume\_host\_path | Represents a directory from node on the host | <pre>list(object({<br>    path_on_node = string<br>    type         = string - (Optional)<br>    volume_name  = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    path_on_node   = "/home/ubuntu"<br>    type           = "Directory"<br>    volume_name    = "node"<br>  }<br>]</pre> | no |
| volume\_config\_map | The data stored in a ConfigMap object can be referenced in a volume of type configMap and then consumed by containerized applications running in a Pod | <pre>list(object({<br>    mode         = string<br>    name         = string<br>    volume_name  = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    mode           = "0777"<br>    name           = "config-map"<br>    volume_name    = "config-volume"<br>  }<br>]</pre> | no |
| volume\_aws\_disk | Represents an AWS Disk resource that is attached to a kubelet's host machine and then exposed to the pod | <pre>list(object({<br>    volume_id    = string<br>    fs_type      = string - (Optional)<br>    partition    = string - (Optional)<br>    read_only    = string - (Optional)<br>    volume_name  = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    volume_id    = "vol-123124123"<br>    volume_name  = "disk"<br>  }<br>]</pre> | no |
| volume\_gce\_disk | Represents an GCE Disk resource that is attached to a kubelet's host machine and then exposed to the pod | <pre>list(object({<br>    volume_name  = string<br>    fs_type      = string - (Optional)<br>    partition    = string - (Optional)<br>    read_only    = string - (Optional)<br>    volume_name  = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    volume_name  = "google-disk-my"<br>    volume_name  = "disk"<br>  }<br>]</pre> | no |
| volume\_empty\_dir | EmptyDir represents a temporary directory that shares a pod's lifetime | <pre>list(object({<br>    volume_name  = string<br>  }))</pre> | n/a | <pre>\[<br>  {<br>    volume_name  = "empty-dir"<br>  }<br>]</pre> | no |

## Outputs
| Name | Description |
|------|:-----------:|
| name | Name of the daemonset |
| namespace | Namespace in which created the daemonset |