resource "aws_sqs_queue" "notification_video_queue" {
  name                       = var.sqsVideoNotificationQueueName
  delay_seconds              = 1
  visibility_timeout_seconds = 600
  message_retention_seconds  = 345600 # 4 dias
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notification_video_queue_dlq.arn,
    maxReceiveCount     = 3,
  })

  tags = {
    Name = var.sqsVideoNotificationQueueName
  }
}

resource "aws_sqs_queue" "notification_video_queue_dlq" {
  name                       = "${var.sqsVideoNotificationQueueName}-dlq"
  visibility_timeout_seconds = 1800
  message_retention_seconds  = 1209600 # 14 days
  tags = {
    Name = "${var.sqsVideoNotificationQueueName}-dlq"
  }
}
