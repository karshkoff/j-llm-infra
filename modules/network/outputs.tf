output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id

}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_01.id, aws_subnet.private_02.id]
}