# Configurar notificações de eventos para o SQS
resource "aws_s3_bucket_notification" "bucket_notifications_videos" {
  bucket = aws_s3_bucket.bucket_videos.id

  queue {
    id        = "mp4-notification"
    queue_arn = aws_sqs_queue.evento_novo_video_queue.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ".mp4"
  }

  queue {
    id        = "avi-notification"
    queue_arn = aws_sqs_queue.evento_novo_video_queue.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ".avi"
  }

  queue {
    id        = "mov-notification"
    queue_arn = aws_sqs_queue.evento_novo_video_queue.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ".mov"
  }

  queue {
    id        = "mkv-notification"
    queue_arn = aws_sqs_queue.evento_novo_video_queue.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ".mkv"
  }

  queue {
    id        = "flv-notification"
    queue_arn = aws_sqs_queue.evento_novo_video_queue.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ".flv"
  }

  queue {
    id        = "wmv-notification"
    queue_arn = aws_sqs_queue.evento_novo_video_queue.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = ".wmv"
  }
}

# Dar permissão para o S3 enviar mensagens para a fila SQS
resource "aws_sqs_queue_policy" "s3_send_message_policy" {
  queue_url = aws_sqs_queue.evento_novo_video_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "SQSQueuePolicy",
    Statement = [
      {
        Sid    = "Allow-S3-Send-Messages",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action   = "SQS:SendMessage",
        Resource = aws_sqs_queue.evento_novo_video_queue.arn,
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.bucket_videos.arn
          }
        }
      },
    ]
  })
}