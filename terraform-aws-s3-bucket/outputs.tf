#This Output strucutre is a Map, every field (key = value) is the entry of map
output "output_data" {
  description = "S3 Bucket details"
  value = {
    name   = aws_s3_bucket.s3_bucket.bucket
    arn    = aws_s3_bucket.s3_bucket.arn
    region = aws_s3_bucket.s3_bucket.region
  }
}

