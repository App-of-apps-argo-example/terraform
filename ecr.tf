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
