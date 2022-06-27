# Platz Terraform Modules For AWS

This repo contains several Terraform modules for deploying Platz in AWS.

The tags in this repo usually correspond to the tags in the Helm charts repo.

## Main Module

The main module deploys Platz itself in an EKS cluster.

It requires the `aws`, `kubernetes` and `helm` providers.

For example (see more below on `chart_discovery` and `k8s_agents`):

```
module "platz" {
  source = "github.com/platzio/terraform-aws-platzio?ref=v0.4.3/modules/main"

  k8s_cluster_name = "EKS CLUSTER NAME"
  domain           = "platz.${aws_route53_zone.ZONE.name}"
  tls_secret_name  = "TLS SECRET"

  oidc_ssm_params = {
    server_url    = "/platz/oidc/server-url"
    client_id     = "/platz/oidc/client-id"
    client_secret = "/platz/oidc/client-secret"
  }

  chart_discovery = module.platz_chart_discovery

  k8s_agents = [
    module.platz_k8s_agent_role,
  ]
}
```

This module can get the following variables:

| Variable            | Required | Default         | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ------------------- | -------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `k8s_cluster_name`  | Yes      |                 | Name of EKS cluster, used for getting credentials                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `k8s_namespace`     |          | `"platz"`       | Kubernetes namespace name, also used as prefix for AWS resources                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `create_namespace`  |          | `true`          | Whether to create the namespace passed in the k8s_namespace variable                                                                                                                                                                                                                                                                                                                                                                                                              |
| `helm_release_name` |          | `"platz"`       | The name of the Helm release                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `chart_version`     |          | Current version | Helm chart version to install/upgrade                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `domain`            | Yes      |                 | Domain to use for ingress, has to match the OIDC domain (see below)                                                                                                                                                                                                                                                                                                                                                                                                               |
| `tls_secret_name`   | Yes      |                 | Secret name to use for ingress TLS                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `oidc_ssm_params`   | Yes      |                 | Mapping containing SSM parameter names for configuring OIDC authentication: `server_url`, `client_id` and `client_secret`                                                                                                                                                                                                                                                                                                                                                         |
| `api_enable_v1`     |          | `false`         | Whether to enable the obsolete `/api/v1` backend paths                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `admin_emails`      |          | `[]`            | Email addresses to add as admins instead of regular users. This option is useful for allowing the first admins to log into Platz on a fresh deployment. Note that admins are added only after successful validation against the OIDC server, and if a user doesn't exist with that email. This means that if an admin is later changed to a regular user role, they will never become an admin again unless their user is deleted from the database, or removed from this option. |
| `use_chart_db`      |          | `true`          | Install the `postgresql` sub-chart (if `false`, you must pass `db_url_override`)                                                                                                                                                                                                                                                                                                                                                                                                  |
| `db_url_override`   |          |                 | Provide an override URL for the database (ignored unless `use_chart_db` is `false`)                                                                                                                                                                                                                                                                                                                                                                                               |
| `chart_discovery`   |          |                 | Contains the IAM role for discovering charts in ECR repos, as created by the chart discovery module described below. The outputs of the chart discovery module match the inputs required by this module, so you can pass the module object directly into this module.                                                                                                                                                                                                             |
| `k8s_agents`        |          |                 | An array of outputs from the K8s agent role modules described below. It works similarly to `chart_discovery`, just pass the module outputs as array elements into this module.                                                                                                                                                                                                                                                                                                    |

## Chart Discovery Module

This module sets up the required permissions and notifications for Platz to detect new Helm charts pushed to ECR.

You should deploy this module in the account where you're hosting your ECR registry.

For example:

```
module "platz_chart_discovery" {
  source = "github.com/platzio/terraform-aws-platzio?ref=v0.4.3/modules/chart-discovery"

  irsa_oidc_provider = (OIDC Provider)
  irsa_oidc_arn      = (OIDC ARN)
}
```

The OIDC provider and ARN are required for allowing Platz to assume into the role
created by this module. These inputs are usually created along with the EKS cluster.

## K8s Agent Role Module

This module creates an IAM role used to discover and connect to EKS clusters.

You'd generally need one role per AWS account, as Platz discovers and connects
to EKS clusters in all regions using the same IAM role.

Example:

```
module "platz_k8s_agent_role" {
  source = "github.com/platzio/terraform-aws-platzio?ref=v0.4.3/modules/k8s-agent-role"

  k8s_agent_name     = "default"
  irsa_oidc_provider = (OIDC Provider)
  irsa_oidc_arn      = (OIDC ARN)
}
```

## Multiple AWS Accounts

If you have more than one AWS account, make sure to choose different names for
`k8s_agent_name` as this name is used for creating the statefulset in Kubernetes
later on.

When creating the k8s-agent-role module in each account, note that the IRSA provider
and ARN must match those of the EKS cluster running Platz.

Since this OIDC provider probably doesn't exist in the remote account where
you're only creating the k8s-agent-role module, you'd also have to create
another OIDC provider with the URL and thumbprint of the controlling EKS
cluster.

For example:

```
# In the remote AWS account only:

resource "aws_iam_openid_connect_provider" "platz_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["<irsa_thumbprint>"]
  url             = "<irsa_issuer_url>"
}

module "platz_k8s_agent_role" {
  source = "github.com/platzio/terraform-aws-platzio?ref=v0.4.3/modules/k8s-agent-role"

  k8s_agent_name     = "prod"
  irsa_oidc_provider = replace(aws_iam_openid_connect_provider.platz_cluster.url, "https://", "")
  irsa_oidc_arn      = aws_iam_openid_connect_provider.platz_cluster.arn
}

```

## Creating Google OAuth Credentials

1. Create a new project at [https://console.cloud.google.com/projectcreate](https://console.cloud.google.com/projectcreate).
2. Wait for the project to create, then click "SELECT PROJECT".
3. Open the hamburger menu, hover over "APIs & Services" and select "Credentials.
4. Click "Configure Consent Screen" and follow the instructions:
   1. Choose "Internal" when asked for a user type, unless you want to allow any person to login to Platz. Choosing "External" is dangerous.
   2. App name: Platz
   3. User support email: (your email)
   4. Developer contact information: (your email)
   5. Click "Save and Continue"
   6. When asked for scopes, simply click "Save and Continue"
   7. When asked for test users, simply click "Save and Continue"
   8. Click "Back to Dashboard"
5. On the left, go back to "Credentials".
6. Click "+ Create Credentials", select "OAuth client ID":
   1. Application type: Web application
   2. Name: Platz
   3. In "Authorized JavaScript origins" click "Add URI" and add the same domain used to deploy Platz, along with an `https://` prefix.
   4. In "Authorized redirect URIs" click "Add URI" and fill-in the same URI with the path `/auth/google/callback`. For example, if the JavaScript origin is `https://example.com` add a redirect URI of `https://example.com/auth/google/callback`.
   5. Click "Create"
7. Use the client ID and secret to create the SSM parameters above.
