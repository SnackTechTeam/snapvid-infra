variable "regionDefault" {
  default = "us-east-1"
}

variable "projectName" {
  default = "vidsnap"
}

variable "vpcCidr" {
  default = "10.0.0.0/16"
}

variable "instanceType" {
  default = "t3a.xlarge"
}

variable "accountIdVoclabs" {
  default = "NNNNNNNNNN"
}

variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}

variable "s3BucketVideosName" {
  default = "vidsnap-videos"
}

variable "sqsVideoStatusQueueName" {
  default = "sqs-video-status"
}

variable "sqsVideoProcessQueueName" {
  default = "sqs-video-novo"
}

variable "sqsVideoNotificationQueueName" {
  default = "sqs-video-notification"
}

variable "rdsVideosDbName" {
  default = "dbvideos"
}

variable "rdsDbVideosUserName" {
  default = "value"
}

variable "rdsDbVideosPassword" {
  default = "value"
}

variable "ecrApiVideosName" {
  default = "api-videos-ecr"
}

variable "ecrWorkerVideosStatusName" {
  default = "worker-videos-status-ecr"
}

variable "ecrWorkerVideosProcessName" {
  default = "worker-videos-process-ecr"
}

variable "cognito_callback_url" {
  default = "https://auth-vidsnap-domain.com/callback"
}

variable "cognito_domain_name" {
  default = "auth-vidsnap-domain"
}