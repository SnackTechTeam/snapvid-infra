# Criar Bucket
resource "aws_s3_bucket" "bucket-videos" {
  bucket = vars.s3BucketVideosName

  tags = {
    Name        = vars.s3BucketVideosName,
    Environment = "Producao"
  }
}

# Bloquear acesso público
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configurar ciclo de vida dos objetos
# Para fins do projeto colocar um tempo curto para evitar cobranças na AWS
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.s3-bucket.id

  rule {
    id     = "delete-old-files"
    status = "Enabled"

    expiration {
      days = 1 
    }

    filter {
      prefix = "" # Aplica a todos os objetos do bucket
    }
  }
}