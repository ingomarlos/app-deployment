# Secrets management
The secrets are managed via External Secrets tool, I have integrated it with AWS Secrets Manager. To make it work, you need to create a secret in AWS Secrets Manager and then create a Kubernetes secret store object. The secret store object will have the name of the secret in AWS Secrets Manager and the name of the Kubernetes secret. The Kubernetes secret will be created by the External Secrets tool.
To make it easier I have automated the management of secrets using Terraform template, all you need to declare the secrets details like below and terraform will create the AWS Secrets Manager resource, IAM Roles/Policies and the Kubernetes manifest for SecretStore and ExternalSecret kinds.

# Example of a secret declaration:
```json
kubernetes_objects = [
  {
    create_aws_secrets = true
    secret_stores      = { "go-app": ["environment", "token"]}
    service_account    = "go-app"
    namespace          = "go-app"
    labels             = "app.kubernetes.io/project=go-app"
  }
]
```

# Example of SecretStore and ExternalSecrets template manifest:
```
%{ for item in kubernetes_objects ~}
  %{ for store_keys, store_items in item.secret_stores ~}

    #
    ## ONLY CREATES THIS BLOCK IF CREATE AWS SECRETS IS SET
    #
    %{ if item.create_aws_secrets != false ~}

          #
          # SECRET STORE CREATION
          #
          resource "aws_secretsmanager_secret" "secret_mng_${store_keys}-${item.namespace}" {
            name        = "${eks_cluster_name}/${item.namespace}/${store_keys}"
            description = "Service Account Password for the API"
            recovery_window_in_days = 0
            tags = var.tags
          }


          resource "kubernetes_manifest" "externalsecret_${store_keys}_${item.namespace}" {
            depends_on = [aws_secretsmanager_secret.secret_mng_${store_keys}-${item.namespace}]
            manifest = {
              "apiVersion" = "external-secrets.io/v1beta1"
              "kind" = "ExternalSecret"
              "metadata" = {
                "name" = "${store_keys}-${item.namespace}"
                "namespace" = "${item.namespace}"
              }
              "spec" = {
                "data" = [
          %{ for store_item in store_items }
                  {
                    "remoteRef" = {
                      "key" = "${eks_cluster_name}/${item.namespace}/${store_keys}"
                      "property" = "${store_item}"
                      "decodingStrategy" = "Auto"
                    }
                    "secretKey" = "${store_item}"
                  },
          %{ endfor ~}
                ]
                "refreshInterval" = "1m"
                "secretStoreRef" = {
                  "kind" = "SecretStore"
                  "name" = "${item.service_account}-${item.namespace}"
                }
                "target" = {
                  "creationPolicy" = "Owner"
                  "name" = "${store_keys}"
                    "template" = {
                      "metadata" = {
                        "labels" = {
                        %{ for label in split(",",item.labels) ~}
                          %{ if label != "" ~}
"${replace(label, "=", "\" = \"") ~}"
                          %{ endif ~}
                        %{ endfor ~}
                        }

                      }
                    } 
                }
              }
            }
          }
      # ENDS AWS SECRETS CREATION BLOCK
      %{ endif ~}
  %{ endfor ~}
%{ endfor ~}
```
