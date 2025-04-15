# Creating S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
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
  count  = var.bucket_encryption == "AES256" || var.bucket_encryption == "aws:kms" ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.bucket_encryption
      kms_master_key_id = var.bucket_encryption == "aws:kms" ? var.custom_kms_key : null # Only set kms_master_key_id if using a custom KMS key

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