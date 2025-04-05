resource "aws_sqs_queue" "sqs_videos_process" {
  name                       = var.sqsVideoProcessQueueName
  delay_seconds              = 0
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 dias
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_videos_process_dlq.arn,
    maxReceiveCount     = 3,
  })

  tags = {
    Name = var.sqsVideoProcessQueueName
  }
}

resource "aws_sqs_queue" "sqs_videos_process_dlq" {
  name                       = "${var.sqsVideoProcessQueueName}-dlq"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600 # 14 days
  tags = {
    Name = "${var.sqsVideoProcessQueueName}-dlq"
  }
}
