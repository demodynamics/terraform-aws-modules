output "output_data" {
  description = "Gitlab CI IAM Role Details"
  value = {
    arn = aws_iam_role.gitlab_ci_role.arn
  }

}
