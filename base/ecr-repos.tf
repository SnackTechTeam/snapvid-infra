resource "aws_ecr_repository" "ecr_api_videos" {
  name = var.ecrApiVideosName
}

resource "aws_ecr_repository" "ecr_worker_videos_status" {
  name = var.ecrWorkerVideosStatusName
}
