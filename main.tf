# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "service" {

  # The name of your service. Up to 255 letters (uppercase and lowercase), numbers, hyphens, and underscores are allowed.
  # Service names must be unique within a cluster, but you can have similarly named services
  # in multiple clusters within a region or across multiple regions.
  name = var.service_name

  # The family and revision (family:revision) or full ARN of the task definition to run in your service.
  # If a revision is not specified, the latest ACTIVE revision is used.
  task_definition = var.task_definition

  # The short name or full Amazon Resource Name (ARN) of the cluster on which to run your service.
  # If you do not specify a cluster, the default cluster is assumed.
  cluster = var.cluster_arn

  # The number of instantiations of the specified task definition to place and keep running on your cluster.
  desired_count = var.desired_task_count

  # The maximumPercent parameter represents an upper limit on the number of your service's tasks
  # that are allowed in the RUNNING or PENDING state during a deployment,
  # as a percentage of the desiredCount (rounded down to the nearest integer).
  deployment_maximum_percent = var.deployment_maximum_percent

  # The minimumHealthyPercent represents a lower limit on the number of your service's tasks
  # that must remain in the RUNNING state during a deployment,
  # as a percentage of the desiredCount (rounded up to the nearest integer).
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  force_new_deployment = var.force_new_deployment

  deployment_controller {
    # The deployment controller type to use. Valid values: CODE_DEPLOY, ECS.
    type = var.deployment_controller_type
  }

  # The network configuration for the service. This parameter is required for task definitions
  # that use the awsvpc network mode to receive their own Elastic Network Interface.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
    # Whether the task's elastic network interface receives a public IP address.
    assign_public_ip = var.assign_public_ip
  }

  # Note: As a result of an AWS limitation, a single load_balancer can be attached to the ECS service at most.
  #
  # When you create any target groups for these services, you must choose ip as the target type, not instance.
  # This is because tasks that use the awsvpc network mode are associated with an elastic network interface, not an EC2 instance.
  #
  # After you create a service, the load balancer name or target group ARN, container name,
  # and container port specified in the service definition are immutable.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-load-balancing.html#load-balancing-concepts
  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      # The ARN of the Load Balancer target group to associate with the service.
      target_group_arn = load_balancer.value.target_group_arn
      # The name of the container to associate with the load balancer (as it appears in a container definition).
      container_name = load_balancer.value.container_name
      # The port on the container to associate with the load balancer.
      container_port = load_balancer.value.container_port
    }
  }

  # If your service's tasks take a while to start and respond to Elastic Load Balancing health checks,
  # you can specify a health check grace period of up to 7,200 seconds. This grace period can prevent
  # the service scheduler from marking tasks as unhealthy and stopping them before they have time to come up.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-create-loadbalancer-rolling.html
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  # You can use either the version number (for example, 1.4.0) or LATEST.
  # If you specify LATEST, your tasks use the most current platform version available,
  # which may not be the most recent platform version.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
  platform_version = var.platform_version

  # The launch type on which to run your service.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html
  launch_type = "FARGATE"

  # Note that Fargate tasks do support only the REPLICA scheduling strategy.
  #
  # The replica scheduling strategy places and maintains the desired number of tasks across your cluster.
  # By default, the service scheduler spreads tasks across Availability Zones.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_replica
  scheduling_strategy = "REPLICA"

  enable_execute_command = var.enable_execute_command
  propagate_tags         = var.propagate_tags

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker != null ? [var.deployment_circuit_breaker] : []
    iterator = d

    content {
      enable   = d.value.enabled
      rollback = d.value.rollback
    }
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  tags = merge(var.tags, {
    "Name" = var.service_name
  })
}
