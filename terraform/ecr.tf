resource "aws_ecr_repository" "app_repo" {
  name                 = "musician-app"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "musician-app"
    Environment = "dev"
    Terraform   = "true"
  }
}
