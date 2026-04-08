locals {
  microservices = [
    "microservice-a",
    "microservice-b",
    "microservice-c"
  ]
}

resource "aws_ecr_repository" "microservices" {
  for_each             = toset(local.microservices)
  name                 = each.key
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_lifecycle_policy" "microservices" {
  for_each   = toset(local.microservices)
  repository = aws_ecr_repository.microservices[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 20 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 20
      }
      action = {
        type = "expire"
      }
    }]
  })
}
