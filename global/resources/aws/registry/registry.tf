resource "aws_ecr_repository" "ecr" {
  name                     = var.uniqueName
  image_tag_mutability     = "MUTABLE"
  tags                     = var.resourceTags

  image_scanning_configuration {
    scan_on_push = true
  }
}
