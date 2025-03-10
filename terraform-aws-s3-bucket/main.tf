terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# Creating S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.default_tags["Project"]}"
  force_destroy = true
}

#Turning on Versioning for our S3 Bucket
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  versioning_configuration {
  status = var.bucket_versioning_status==true?"Enabled":"Disabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.bucket_encryption
    }
  }
}

/*
 #Creating Object (folder and subfolders) inside S3 Bucket
 resource "aws_s3_object" "s3_bucket_object" {
   bucket                 = aws_s3_bucket.s3_bucket.bucket
   key                    = var.bucket_key
   server_side_encryption = var.bucket_encryption
 }
*/