output "output_data" {
  description = "GithHub Actions IAM Role Details"
    value = {
        arn = aws_iam_role.github_actions_role.arn
    }
  
}