resource "aws_sqs_queue" "sqs_atualiza_status" {
  name                       = var.sqsVideoStatusQueueName
  delay_seconds              = 0
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 dias
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_atualiza_status_dlq.arn,
    maxReceiveCount     = 3,
  })

  tags = {
    Name = var.sqsVideoStatusQueueName
  }
}

resource "aws_sqs_queue" "sqs_atualiza_status_dlq" {
  name                       = "${var.sqsVideoStatusQueueName}-dlq"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600 # 14 days
  tags = {
    Name = "${var.sqsVideoStatusQueueName}-dlq"
  }
}
