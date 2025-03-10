#1st Type # This Output strucutre is a Map, every field (key = value) is the entry of map
output "s3_bucket_data" {
  description = "S3 Bucket Data"
  value = {
    "Bucket Name"   = aws_s3_bucket.s3_bucket.bucket
    "Bucket Arn"    = aws_s3_bucket.s3_bucket.arn
    "Bucket Region" = aws_s3_bucket.s3_bucket.region
  }
}

/*
# 2nd Type# This Output strucutre is a List of maps
output "s3_bucket_data" {
  description = "S3 Bucket Data"
  value = [
    { "Bucket Name"                                     : aws_s3_bucket.s3_bucket.bucket},
    { "${aws_s3_bucket.s3_bucket.bucket} Bucket Arn"    : aws_s3_bucket.s3_bucket.arn},
    { "${aws_s3_bucket.s3_bucket.bucket} Bucket Region" : aws_s3_bucket.s3_bucket.region },
    { "${aws_s3_bucket.s3_bucket.bucket} Bucket Keys"   : aws_s3_object.s3_bucket_object.key }
  ]
}
*/



#✅ If you want a well-structured output → Use the first version` map.
#✅ If you need an List of separate key-value pairs → Use the second version` list of maps, but this is less common.

