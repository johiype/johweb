resource "aws_ecr_repository" "johweb-docker-image-repo" {
        name = "${var.ecr_name}"
        image_tag_mutability = "MUTABLE"

        image_scanning_configuration {
                scan_on_push = false
        }
}
