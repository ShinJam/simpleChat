output "id" {
  value       = module.redis.id
  description = "Redis cluster ID"
}
output "endpoint" {
  value       = module.redis.endpoint
  description = "Redis primary or configuration endpoint, whichever is appropriate for the given cluster mode"
}
output "arn" {
  value       = module.redis.arn
  description = "Elasticache Replication Group ARN"
}
