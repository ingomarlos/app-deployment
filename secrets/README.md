# Secrets management
The secrets are managed via External Secrets tool, I have integrated it with AWS Secrets Manager. To make it work, you need to create a secret in AWS Secrets Manager and then create a Kubernetes secret store object. The secret store object will have the name of the secret in AWS Secrets Manager and the name of the Kubernetes secret. The Kubernetes secret will be created by the External Secrets tool.
To make it easier I have automated the management of secrets using Terraform template, all you need to declare the secrets details like below and terraform will create the AWS Secrets Manager resource, IAM Roles/Policies and the Kubernetes manifest for SecretStore and ExternalSecret kinds.

# Example of a secret declaration:
```
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

%{ for item in create_namespaces ~}

    resource "kubernetes_namespace" "${item}-ns" {
      metadata {
        name = "${item}"
      }
    }
    
# %{ endfor ~}

#
# AWS SECRETS MANAGER SECRET STORE FOR K8S WILL BE CREATE IN THIS FILE
#

%{ for item in kubernetes_objects ~}

#
# SERVICE ACCOUNT CREATION
#
###########
    resource "kubernetes_service_account" "${item.service_account}" {
      #depends_on = ["kubernetes_namespace.${item.namespace}-ns"]
      metadata {
        name        = "${item.service_account}"
        namespace   = "${item.namespace}"
      annotations = {
        "eks.amazonaws.com/role-arn" = "$${aws_iam_role.secret_mng_${item.service_account}-${item.namespace}.arn}"
    }
      }
    }

    resource "aws_iam_role" "secret_mng_${item.service_account}-${item.namespace}" {
      name = "${eks_cluster_name}-${substr(md5("${eks_cluster_name}-${item.namespace}-${item.service_account}"),0,5)}-iam-role"
      tags = var.tags

      assume_role_policy = jsonencode({
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Principal" : {
              "Federated" : "$${data.terraform_remote_state.ACME_aws_shared_eks_data.outputs.oidc_provider_arn}"
            },
            "Action" : "sts:AssumeRoleWithWebIdentity",
            "Condition" : {
              "StringEquals" : {
                "$${data.terraform_remote_state.ACME_aws_shared_eks_data.outputs.oidc_provider}:aud" : "sts.amazonaws.com",
                "$${data.terraform_remote_state.ACME_aws_shared_eks_data.outputs.oidc_provider}:sub" : "system:serviceaccount:${item.namespace}:${item.service_account}"
              }
            }
          }
        ]
      })
    }


########## properties secret_stores
#
## ONLY CREATES THIS BLOCK IF CREATE AWS SECRETS IS SET
#
    %{ if item.create_aws_secrets != false ~}

      resource "aws_iam_policy" "secret_mng_${item.service_account}-${item.namespace}" {
        name   = "${eks_cluster_name}-${substr(md5("${eks_cluster_name}-${item.namespace}-${item.service_account}"),0,5)}-iam-policy"
        path   = "/"
        tags = var.tags
        policy = jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "VisualEditor0",
                    "Effect": "Allow",
                    "Action": [
                        "secretsmanager:GetResourcePolicy",
                        "secretsmanager:GetSecretValue",
                        "secretsmanager:DescribeSecret",
                        "secretsmanager:ListSecretVersionIds"
                    ],
                    "Resource": [ %{ for store_keys, store_items in item.secret_stores } "$${resource.aws_secretsmanager_secret.secret_mng_${store_keys}-${item.namespace}.arn}",  %{ endfor } ]
                },
                {
                    "Sid": "VisualEditor1",
                    "Effect": "Allow",
                    "Action": [
                        "secretsmanager:GetRandomPassword",
                        "secretsmanager:ListSecrets"
                    ],
                    "Resource": "*"
                }
            ]
        })
      }

      resource "aws_iam_role_policy_attachment" "secret_mng_${item.service_account}-${item.namespace}" {
        role       = aws_iam_role.secret_mng_${item.service_account}-${item.namespace}.name
        policy_arn = aws_iam_policy.secret_mng_${item.service_account}-${item.namespace}.arn
      }

      resource "kubernetes_manifest" "secretstore_secrets_${item.service_account}-${item.namespace}" {
        manifest = {
          "apiVersion" = "external-secrets.io/v1beta1"
          "kind" = "SecretStore"
          "metadata" = {
            "name" = "${item.service_account}-${item.namespace}"
            "namespace" = "${item.namespace}"
          }
          "spec" = {
            "provider" = {
              "aws" = {
                "auth" = {
                  "jwt" = {
                    "serviceAccountRef" = {
                      "name" = "${item.service_account}"
                    }
                  }
                }
                "region" = "eu-central-1"
                "service" = "SecretsManager"
              }
            }
          }
        }
      }
  # ENDS AWS SECRETS CREATION BLOCK
  %{ endif ~}

%{ endfor ~}




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
