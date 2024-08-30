variable "service_name" {
  type        = string
  description = "Name of the ECS service"
}

variable "deployment_controller_type" {
  default     = "ECS"
  type        = string
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS."
}

variable "platform_version" {
  default     = "1.4.0"
  type        = string
  description = "The platform version on which to run your service."
}

variable "task_definition" {
  type        = string
  description = "Task definition ARN"
}

variable "cluster_arn" {
  type        = string
  description = "The ARN of the cluster where the service will run"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The Subnet IDs of the service."
}

variable "security_group_ids" {
  type        = list(string)
  description = "The Security Group IDs of the service."
}

variable "load_balancers" {
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = string
  }))
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers."
  default     = 30
  validation {
    condition     = var.health_check_grace_period_seconds > 0 && var.health_check_grace_period_seconds <= 2147483647
    error_message = "Value for health_check_grace_period_seconds must be greater than 0 and less than or equal to 2147483647."
  }
}

variable "desired_task_count" {
  type        = number
  description = "Desired number of tasks to be running for this ecs service"
  default     = 1
}

variable "deployment_maximum_percent" {
  description = "The upper limit, as a percentage of var.desired_number_of_tasks, of the number of running ECS Tasks that can be running in a service during a deployment. Setting this to more than 100 means that during deployment, ECS will deploy new instances of a Task before undeploying the old ones."
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "The lower limit, as a percentage of var.desired_number_of_tasks, of the number of running ECS Tasks that must remain running and healthy in a service during a deployment. Setting this to less than 100 means that during deployment, ECS may undeploy old instances of a Task before deploying new ones."
  default     = 50
}

variable "force_new_deployment" {
  type        = bool
  description = "Enable to force a new task deployment of the service"
  default     = false
}

variable "deployment_circuit_breaker" {
  type = object({
    enabled  = bool
    rollback = bool
  })
  description = "Whether ECS deployment circuit breaker should be enabled (enabled attribute), and whether ECS should automatically rollback the service when tasks consistently fail (rollback attribute): https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_DeploymentCircuitBreaker.html"
  default     = null
}

variable "enable_execute_command" {
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  type        = bool
  default     = false
}

variable "propagate_tags" {
  description = "(Optional) Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION."
  type        = string
  default     = "TASK_DEFINITION"

  validation {
    condition     = var.propagate_tags == null || var.propagate_tags == "SERVICE" || var.propagate_tags == "TASK_DEFINITION"
    error_message = "Value of propagate_tags must be one of SERVICE or TASK_DEFINITION or null."
  }
}

variable "tags" {
  description = "Tags for aws resources"
  type        = map(string)
  default     = null
}
