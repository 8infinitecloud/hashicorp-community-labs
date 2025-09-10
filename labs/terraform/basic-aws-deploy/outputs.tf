output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.lab_bucket.arn
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.lab_instance.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.lab_instance.public_ip
}
