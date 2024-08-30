output "service_name" {
  description = "The name of the ECS Service"
  value       = aws_ecs_service.service.name
}
