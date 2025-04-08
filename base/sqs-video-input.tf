resource "aws_sqs_queue" "evento_novo_video_queue" {
  name                       = var.sqsNovoVideoQueueName
  delay_seconds              = 0
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 dias
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.evento_novo_video_queue_dlq.arn,
    maxReceiveCount     = 3,
  })

  tags = {
    Name = var.sqsNovoVideoQueueName
  }
}

resource "aws_sqs_queue" "evento_novo_video_queue_dlq" {
  name                       = "${var.sqsNovoVideoQueueName}-dlq"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600 # 14 days
  tags = {
    Name = "${var.sqsNovoVideoQueueName}-dlq"
  }
}
