output "queue_arns" {
  value = aws_sqs_queue.this[*].arn
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

output "private_subnets_arns" {
  value = aws_subnet.private[*].arn
}

output "public_subnets_arns" {
  value = aws_subnet.public[*].arn
}
