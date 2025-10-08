output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_01.id, aws_subnet.private_02.id]
}