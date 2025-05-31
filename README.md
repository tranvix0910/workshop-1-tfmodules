# Terraform Modules - AWS Student Management Project

## Table of Contents
- [bastion](#bastion)
- [iam](#iam)
- [security](#security)
- [networking](#networking)
- [load_balancer](#load_balancer)
- [ecs_cluster](#ecs_cluster)
- [database](#database)
- [How to generate SSH key for Bastion](#how-to-generate-ssh-key-for-bastion)
- [How to use Terraform](#how-to-use-terraform)

---

## bastion
This module creates a Bastion Host (EC2) for internal system access and installs the MongoDB client.
- **Input:**
  - `vpc_security_group_ids` (list(string)): Security group IDs for the EC2
  - `subnet_id` (string): Subnet for the EC2
  - `ami_id` (string): AMI to use
  - `public_key_path` (string): Path to the public key file
  - `instance_type` (string): EC2 instance type
- **Output:**
  - `bastion_host_public_ip`: Public IP of the Bastion
  - `bastion_host_private_ip`: Private IP of the Bastion

## iam
This module creates IAM Roles and Policies for ECS Task Execution and Task Role.
- **Input:**
  - `task_execution_role_name` (string)
  - `task_execution_policy_name` (string)
  - `task_role_name` (string)
  - `task_role_policy_name` (string)
- **Output:**
  - `task_execution_role_arn`: ARN of the Task Execution Role
  - `task_role_arn`: ARN of the Task Role

## security
This module creates Security Groups for public, private, bastion, and database resources.
- **Input:**
  - `vpc_id` (string): VPC ID
- **Output:**
  - `public_sg_id`, `private_sg_id`, `bastion_sg_id`, `database_sg_id`: Security group IDs

## networking
This module creates a VPC, public/private subnets, and a subnet group for MongoDB.
- **Input:**
  - `vpc_cidr` (string): CIDR block for the VPC
  - `vpc_azs` (list(string)): List of Availability Zones
  - `vpc_private_subnets` (list(string))
  - `vpc_public_subnets` (list(string))
  - `vpc_public_subnet_names` (list(string))
  - `vpc_private_subnet_names` (list(string))
  - `vpc_name` (string)
- **Output:**
  - `vpc_id`, `vpc_arn`, `public_subnet_ids`, `private_subnet_ids`

## load_balancer
This module creates an Application Load Balancer and target groups for frontend/backend.
- **Input:**
  - `vpc_id` (string)
  - `vpc_security_group_ids` (list(string))
  - `subnets` (list(string))
  - `load_balancer_name` (string)
- **Output:**
  - `frontend_target_group_arn`, `backend_target_group_arn`, `alb_arn`, `alb_dns`, `alb_dns_backend`

## ecs_cluster
This module creates an ECS Cluster, ECS Services for frontend/backend, and CloudWatch log groups.
- **Input:**
  - `ecs_region` (string)
  - `ecs_task_execution_role_arn` (string)
  - `ecs_task_role_arn` (string)
  - `frontend_ecr_image_url` (string)
  - `alb_dns_backend` (string)
  - `ecs_subnet_ids` (list(string))
  - `ecs_security_group_ids` (list(string))
  - `frontend_target_group_arn` (string)
  - `backend_ecr_image_url` (string)
  - `mongodb_connection_string_secret_arn` (string)
  - `ecs_backend_target_group_arn` (string)
  - `ecs_cluster_name` (string)
  - `frontend_log_group_name` (string)
  - `backend_log_group_name` (string)
  - `frontend_container_name` (string)
  - `backend_container_name` (string)
- **Output:**
  - (No explicit output, check the code for more details if needed)

## database
This module creates DocumentDB (MongoDB compatible), connection secrets, and subnet group.
- **Input:**
  - `db_username` (string)
  - `db_subnet_group` (list(string))
  - `db_security_group_ids` (list(string))
- **Output:**
  - `mongodb_connection_string`: MongoDB connection string
  - `mongodb_cluster_endpoint`: Cluster endpoint
  - `mongodb_secret_arn`: Secret ARN
  - `mongodb_connection_string_arn`: Connection string secret ARN

---

## How to generate SSH key for Bastion
To create a new SSH key pair for the Bastion Host, run the following command (replace `bastion-key` with your preferred key name):

```sh
ssh-keygen -t rsa -b 4096 -f ./Key/bastion-key
```

- This will generate two files: `bastion-key` (private key) and `bastion-key.pub` (public key) in the `Key` directory.
- Use the path to the public key (e.g., `./Key/bastion-key.pub`) as the value for the `public_key_path` variable in the bastion module.
- **Keep your private key secure and do not commit it to version control.**

## How to use Terraform
1. **Initialize Terraform:**
   ```sh
   terraform init
   ```
2. **Validate the configuration:**
   ```sh
   terraform validate
   ```
3. **Plan the deployment:**
   ```sh
   terraform plan -out=tfplan
   ```
4. **Apply the plan:**
   ```sh
   terraform apply tfplan
   ```
5. **(Optional) Destroy resources:**
   ```sh
   terraform destroy
   ```

> **Note:**
> - Make sure your AWS credentials are configured (via environment variables or AWS CLI).
> - Review and adjust variable values as needed for your environment.
> - For more details, refer to each module's code and comments.
