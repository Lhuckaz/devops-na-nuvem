resource "aws_sqs_queue" "this" {
  count = length(var.queues)

  name                      = var.queues[count.index].name
  delay_seconds             = var.queues[count.index].delay_seconds
  max_message_size          = var.queues[count.index].max_message_size
  message_retention_seconds = var.queues[count.index].message_retention_seconds
  receive_wait_time_seconds = var.queues[count.index].receive_wait_time_seconds
}
