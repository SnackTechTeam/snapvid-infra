output "rds_videos_instance_address" {
  value = aws_db_instance.snacktech_db_videos.address
  description = "Endereço da instancia RDS do banco de videos"
}