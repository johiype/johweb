resource "aws_ecr_repository" "johweb-docker-image-repo" {
        name = "${var.ECR_NAME}"
        image_tag_mutability = "MUTABLE"

        image_scanning_configuration {
                scan_on_push = false
        }
}
