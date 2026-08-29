# HCP Terraform — Remote Execution and Remote State Management

This README documents the end-to-end setup demonstrated in the accompanying **HCP Terraform** walkthrough. The original document has been reviewed and the wording has been corrected for grammar, clarity, consistency, and technical readability while retaining the workflow and terminology used in the source material.

> **Scope:** The walkthrough covers account creation, organization/project/workspace setup, CLI-driven remote execution, API-token authentication, AWS credential configuration, remote state management, configuration changes, and resource destruction.

---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Prerequisites](#2-prerequisites)
- [3. Create an HCP Terraform Account](#3-create-an-hcp-terraform-account)
- [4. Confirm the Account](#4-confirm-the-account)
- [5. Create an HCP Terraform Organization](#5-create-an-hcp-terraform-organization)
- [6. Create a Project](#6-create-a-project)
- [7. Create a Workspace](#7-create-a-workspace)
- [8. Configure the Terraform Cloud Block](#8-configure-the-terraform-cloud-block)
- [9. Create an HCP Terraform API Token](#9-create-an-hcp-terraform-api-token)
- [10. Authenticate the Terraform CLI](#10-authenticate-the-terraform-cli)
- [11. Initialize and Execute Terraform](#11-initialize-and-execute-terraform)
- [12. Configure AWS Credentials](#12-configure-aws-credentials)
- [13. Run Terraform Apply](#13-run-terraform-apply)
- [14. Verify Remote State Management](#14-verify-remote-state-management)
- [15. Make a Configuration Change](#15-make-a-configuration-change)
- [16. Destroy the Infrastructure](#16-destroy-the-infrastructure)
- [17. End-to-End Workflow](#17-end-to-end-workflow)
- [18. Security Recommendations](#18-security-recommendations)
- [19. Key Takeaways](#19-key-takeaways)

---

# 1. Overview

**HCP Terraform** provides centralized Terraform workspace management, remote execution, run history, variables, and remote state management.

The walkthrough demonstrates the following flow:

```text
Terraform CLI
     |
     | Authentication
     v
HCP Terraform
     |
     | CLI-driven remote run
     v
Terraform Workspace
     |
     +---- Remote State
     |
     +---- Workspace Variables
     |
     v
AWS Provider
     |
     v
AWS Resources
```

The practical example creates an **AWS EC2 instance**, updates its configuration, and finally destroys it.

---

# 2. Prerequisites

Before starting, ensure that you have:

- Terraform installed on your local machine.
- An HCP Terraform account.
- Access to an AWS account.
- Permission to create the AWS resources required by your Terraform configuration.
- A Terraform configuration that defines the required provider and resources.
- An HCP Terraform API token for CLI authentication.

---

# 3. Create an HCP Terraform Account

Open the HCP Terraform login page:

**https://app.terraform.io/login**

You can create an account using a username/email-based approach. If you already have a HashiCorp account, you can use that account. The walkthrough also demonstrates using **GitHub SSO**.

![HCP Terraform login page](images/hcp-image-01.png)

![Create Terraform account](images/hcp-image-02.png)

The account creation screen requires the username, email address, password, and acceptance of the applicable terms.

---

# 4. Confirm the Account

The walkthrough describes two ways to establish the HCP Terraform login:

1. **Email-based account creation and verification**
2. **GitHub SSO**

## Approach 1 — Email verification

After creating the account, HCP Terraform requires the email address to be confirmed.

![HashiCorp account creation and authentication options](images/hcp-image-03.png)

The account confirmation screen provides the option to resend the confirmation link if required.

![HCP Terraform email confirmation screen](images/hcp-image-04.png)

Open the confirmation email and select the confirmation link.

![HCP Terraform email confirmation message](images/hcp-image-05.png)

After confirmation, sign in using the email address used to create the HCP Terraform account.

![HCP Terraform sign-in page](images/hcp-image-06.png)

## Approach 2 — GitHub SSO

If GitHub is used for authentication, authorize HashiCorp to access the required GitHub account information.

![GitHub authentication flow](images/hcp-image-07.png)

Authorize the HashiCorp application.

![Authorize HashiCorp through GitHub](images/hcp-image-08.png)

After authorization, HCP Terraform creates an HCP-linked account that can be used to access HashiCorp services.

![HCP-linked account screen](images/hcp-image-09.png)

---

# 5. Create an HCP Terraform Organization

After logging in, create your first HCP Terraform organization.

Select **Create organization** and provide the required organization details.

![Create first HCP Terraform organization](images/hcp-image-10.png)

A new organization is created with a **Default Project**.

---

# 6. Create a Project

A workspace can be created under the default project, or a separate project can be created to organize related workspaces.

For this walkthrough, a new project is created.

![Create a new HCP Terraform project](images/hcp-image-11.png)

The project is then available in the organization's project list.

![HCP Terraform project list](images/hcp-image-12.png)

A useful logical structure is:

```text
Organization
└── Project
    └── Workspace
```

---

# 7. Create a Workspace

Create the workspace under the newly created project.

HCP Terraform provides three workspace workflow options:

| Workflow | Purpose |
|---|---|
| **Version Control Workflow** | Runs Terraform based on changes in a connected source-control repository such as GitHub or Bitbucket. |
| **CLI-Driven Workflow** | Uses the Terraform CLI to trigger Terraform runs in HCP Terraform. |
| **API-Driven Workflow** | Uses the HCP Terraform API and is commonly used for custom CI/CD integrations. |

For this walkthrough, select **CLI-Driven Workflow**.

![HCP Terraform workspace creation](images/hcp-image-13.png)

![Select CLI-driven workflow](images/hcp-image-14.png)

Provide a workspace name under **Configuration Settings**, select the project, and click **Create**.

![Configure HCP Terraform workspace](images/hcp-image-15.png)

The workspace is then created under the selected project.

![Newly created HCP Terraform workspace](images/hcp-image-16.png)

---

# 8. Configure the Terraform Cloud Block

The HCP Terraform workspace provides a Terraform configuration snippet that connects the local Terraform configuration to the remote workspace.

An example from the walkthrough is:

```hcl
terraform {
  required_version = ">= 1.16.0"

  cloud {
    organization = "LTC_Terraform_Cohort"

    workspaces {
      name = "RemoteTerraformRun_CLI"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

Add the appropriate HCP Terraform configuration to your Terraform code.

![HCP Terraform cloud configuration snippet](images/hcp-image-17.png)

The important relationship is:

```text
Terraform CLI
     |
     v
HCP Terraform Organization
     |
     v
HCP Terraform Workspace
```

> **Note:** Replace the example organization and workspace names with the names used in your own HCP Terraform environment.

---

# 9. Create an HCP Terraform API Token

The Terraform CLI must authenticate with HCP Terraform before it can trigger remote runs.

Navigate to the account token settings and select **Create an API token**.

![HCP Terraform profile and token settings](images/hcp-image-18.png)

![HCP Terraform token creation option](images/hcp-image-19.png)

Specify how long the token should remain valid.

![Select API token expiration period](images/hcp-image-20.png)

Enter a description and click **Generate Token**.

![Generate HCP Terraform API token](images/hcp-image-21.png)

Copy the token immediately after it is generated.

**Important:** Do not share the token or commit it to source control. Treat it as a password.

---

# 10. Authenticate the Terraform CLI

On your local machine, execute:

```bash
terraform login
```

Terraform asks whether it should proceed with authentication.

![Run terraform login](images/hcp-image-22.png)

Enter:

```text
yes
```

Terraform then asks you to provide the token for `app.terraform.io`.

![Confirm terraform login](images/hcp-image-23.png)

![Enter HCP Terraform API token](images/hcp-image-24.png)

Enter the API token generated in HCP Terraform.

If authentication succeeds, Terraform confirms that the token has been retrieved and the CLI can communicate with HCP Terraform.

The walkthrough shows Terraform storing the credentials locally for subsequent commands.

---

# 11. Initialize and Execute Terraform

After authentication, initialize the Terraform working directory:

```bash
terraform init
```

Terraform downloads the required providers and initializes the HCP Terraform integration.

![Successful terraform init and HCP Terraform authentication](images/hcp-image-25.png)

You can then run:

```bash
terraform plan
```

or:

```bash
terraform apply
```

The Terraform CLI triggers a run in the configured HCP Terraform workspace.

---

# 12. Configure AWS Credentials

The example Terraform configuration creates an AWS EC2 instance.

When Terraform runs remotely in HCP Terraform, the workspace must have permission to authenticate to AWS.

If AWS credentials have not been configured, the remote run fails because HCP Terraform cannot authenticate with AWS.

![Terraform apply failure caused by missing AWS credentials](images/hcp-image-26.png)

The walkthrough demonstrates the failed run and the resulting error.

![HCP Terraform run showing AWS credential error](images/hcp-image-27.png)

## Fix the error

Open the HCP Terraform workspace and navigate to:

**Variables → Add variable**

![HCP Terraform workspace variables](images/hcp-image-28.png)

Add the required AWS credentials as **Environment Variables**.

Typical variables include:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Mark sensitive credentials as **Sensitive**.

![Add AWS access key environment variable](images/hcp-image-29.png)

![Add AWS secret access key environment variable](images/hcp-image-30.png)

After adding the credentials, verify that the variables are present in the workspace and marked sensitive.

![HCP Terraform sensitive workspace variables](images/hcp-image-31.png)

> **Security:** Never hard-code AWS credentials in Terraform source code and never commit them to GitHub.

---

# 13. Run Terraform Apply

Run the apply operation again:

```bash
terraform apply
```

The Terraform CLI triggers a remote run in HCP Terraform.

The walkthrough demonstrates that the **run ID displayed by the CLI and the run shown in the HCP Terraform console correspond to the same operation**.

![Terraform apply and corresponding HCP Terraform run](images/hcp-image-32.png)

The plan is successful, but Terraform requests confirmation before applying the changes.

![Terraform plan awaiting confirmation](images/hcp-image-33.png)

![Terraform apply confirmation](images/hcp-image-34.png)

Once confirmed, HCP Terraform executes the changes.

![Successful Terraform apply](images/hcp-image-35.png)

The AWS console can then be used to verify that the EC2 instance has been created.

![AWS EC2 instance created by Terraform](images/hcp-image-36.png)

---

# 14. Verify Remote State Management

With HCP Terraform configured for remote execution, Terraform state is managed by HCP Terraform.

The walkthrough verifies that a local:

```text
terraform.tfstate
```

file is not created in the working directory because the state is maintained remotely.

![Terraform configuration and local working directory](images/hcp-image-37.png)

Conceptually:

```text
Local Terraform CLI
        |
        | Remote execution
        v
HCP Terraform Workspace
        |
        +---- Remote Terraform State
        |
        v
       AWS
```

This centralizes state management in the HCP Terraform workspace instead of maintaining the state file locally.

---

# 15. Make a Configuration Change

To demonstrate the update workflow, modify the Terraform configuration by adding a new tag to the EC2 instance.

The walkthrough adds a tag similar to:

```hcl
tags = {
  Name      = "LTC-HYD-Linux-EC2"
  Project   = "LTC_HYD_PROJECT"
  ManagedBy = "Terraform"
  This_is   = "LTC"
}
```

![Terraform configuration with an additional EC2 tag](images/hcp-image-38.png)

Run:

```bash
terraform apply
```

HCP Terraform detects the configuration change and creates a new remote run.

![HCP Terraform run triggered after configuration change](images/hcp-image-39.png)

The plan shows the tag update.

![Terraform plan showing EC2 tag update](images/hcp-image-40.png)

![Terraform apply for EC2 tag update](images/hcp-image-41.png)

After the run completes, verify the new tag in the AWS console.

![New EC2 tag visible in AWS](images/hcp-image-42.png)

This demonstrates the change-management flow:

```text
Modify Terraform configuration
             |
             v
      terraform apply
             |
             v
       HCP Terraform
             |
             v
      Remote Terraform Run
             |
             v
        AWS Resource
```

---

# 16. Destroy the Infrastructure

To remove the EC2 instance managed by Terraform, run:

```bash
terraform destroy
```

The command creates a destruction plan and requests confirmation.

![Terraform destroy initiated from the CLI](images/hcp-image-43.png)

![Terraform destroy plan](images/hcp-image-44.png)

Confirm the destruction operation.

![Terraform destroy confirmation](images/hcp-image-45.png)

HCP Terraform executes the destroy operation remotely.

![Terraform destroy operation in progress](images/hcp-image-46.png)

After the operation completes, Terraform reports that the resource has been destroyed.

![Terraform destroy completed successfully](images/hcp-image-47.png)

The AWS console can then be used to verify that the EC2 resource has been removed.

![AWS console after Terraform destroy](images/hcp-image-48.png)

The HCP Terraform workspace retains the run history, allowing previous successful and failed runs to be reviewed.

![HCP Terraform run history](images/hcp-image-49.png)

---

# 17. End-to-End Workflow

The complete workflow demonstrated in the document can be summarized as follows:

```text
+---------------------------+
| Create HCP Terraform     |
| Account                   |
+-------------+-------------+
              |
              v
+---------------------------+
| Create Organization       |
+-------------+-------------+
              |
              v
+---------------------------+
| Create Project            |
+-------------+-------------+
              |
              v
+---------------------------+
| Create Workspace          |
| CLI-Driven Workflow       |
+-------------+-------------+
              |
              v
+---------------------------+
| Configure Terraform       |
| cloud block               |
+-------------+-------------+
              |
              v
+---------------------------+
| Create HCP API Token      |
+-------------+-------------+
              |
              v
+---------------------------+
| terraform login           |
+-------------+-------------+
              |
              v
+---------------------------+
| terraform init            |
+-------------+-------------+
              |
              v
+---------------------------+
| Configure AWS Credentials |
| as sensitive variables    |
+-------------+-------------+
              |
              v
+---------------------------+
| terraform plan/apply      |
+-------------+-------------+
              |
              v
+---------------------------+
| AWS EC2 Instance Created  |
+-------------+-------------+
              |
              v
+---------------------------+
| Modify Terraform          |
| Configuration             |
+-------------+-------------+
              |
              v
+---------------------------+
| terraform apply            |
+-------------+-------------+
              |
              v
+---------------------------+
| AWS Resource Updated      |
+-------------+-------------+
              |
              v
+---------------------------+
| terraform destroy         |
+-------------+-------------+
              |
              v
+---------------------------+
| AWS Resource Removed      |
+---------------------------+
```

---

# 18. Security Recommendations

The source walkthrough demonstrates API tokens and AWS credentials. For a production implementation, follow these practices:

- **Never commit HCP Terraform API tokens to GitHub.**
- **Never commit AWS access keys or secret keys to GitHub.**
- Store credentials as sensitive HCP Terraform workspace variables or use an appropriate dynamic/cloud credential mechanism.
- Use short-lived credentials where possible.
- Set appropriate expiration periods for API tokens.
- Rotate credentials regularly.
- Follow least-privilege permissions for AWS identities.
- Use separate workspaces for different environments where appropriate.
- Protect production workspaces with appropriate access controls and approval mechanisms.
- Remove or rotate credentials that may have been exposed in screenshots or documentation.
- Avoid including real personal email addresses, tokens, account identifiers, or other secrets in repository documentation.

---

# 19. Key Takeaways

### Remote Terraform Execution

The Terraform CLI can be used as the interface while HCP Terraform manages the remote Terraform run.

### Remote State

HCP Terraform manages the Terraform state remotely, avoiding the need to maintain a local `terraform.tfstate` file for this workflow.

### Workspace Variables

AWS credentials required by the remote run can be configured at the HCP Terraform workspace level and marked as sensitive.

### Run Visibility

The Terraform CLI and HCP Terraform console provide visibility into the same remote Terraform run.

### Infrastructure Lifecycle

The demonstrated workflow supports the complete lifecycle:

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

### Organization Structure

HCP Terraform provides a structured hierarchy:

```text
Organization
    |
    +-- Project
          |
          +-- Workspace
                |
                +-- Variables
                +-- Runs
                +-- Remote State
```

---

## Conclusion

This walkthrough demonstrates how HCP Terraform can be used to provide **centralized remote Terraform execution and remote state management**.

The example starts with account and workspace creation, authenticates the Terraform CLI, configures AWS credentials, creates an EC2 instance, updates its configuration, and finally destroys the infrastructure.

The resulting workflow provides a foundation for integrating Terraform into a broader **GitHub/CI/CD-based infrastructure automation process**, while keeping Terraform execution and state management centralized in HCP Terraform.
