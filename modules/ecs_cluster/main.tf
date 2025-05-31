# Create ECS Cluster
resource "aws_ecs_cluster" "student_management_ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name = var.frontend_log_group_name
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "frontend-task-definition"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "512"
  memory                = "1024"
  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.frontend_container_name}",
      "image": "${var.frontend_ecr_image_url}",
      "environment": [
        {
          "name": "REACT_APP_API_URL",
          "value": "${var.alb_dns_backend}" 
        }
      ],
      "cpu": 512,
      "memory": 1024,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.frontend_log_group.name}",
          "awslogs-region": "${var.ecs_region}",
          "awslogs-stream-prefix": "${var.frontend_container_name}"
        }
      }
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "frontend_service" {
  name            = "${var.frontend_container_name}"
  network_configuration {
    subnets = var.ecs_subnet_ids
    security_groups = var.ecs_security_group_ids
    assign_public_ip = true
  }
  cluster         = aws_ecs_cluster.student_management_ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "${var.frontend_container_name}"
    container_port   = 80
  }
}

# Backend
resource "aws_cloudwatch_log_group" "backend_log_group" {
  name = "ecs/${var.backend_container_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "backend_task_definition" {
  family                   = "backend-task-definition"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = "512"
  memory                = "1024"
  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.backend_container_name}",
      "image": "${var.backend_ecr_image_url}",
      "cpu": 512,
      "memory": 1024,
      "secrets": [
        {
          "name": "MONGO_URL",
          "valueFrom": "${var.mongodb_connection_string_secret_arn}"
        }
      ],
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.backend_log_group.name}",
          "awslogs-region": "${var.ecs_region}",
          "awslogs-stream-prefix": "${var.backend_container_name}"
        }
      }
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "backend_service" {
  name = "${var.backend_container_name}"
  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = var.ecs_security_group_ids
    assign_public_ip = true
  }
  cluster         = aws_ecs_cluster.student_management_ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.ecs_backend_target_group_arn
    container_name   = "${var.backend_container_name}"
    container_port   = 8080
  }
}

