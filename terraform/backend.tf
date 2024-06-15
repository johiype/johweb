terraform {
	backend "s3" {
		bucket = "johweb-terra-state"
    		key = "terraform/backend"
    		region = "us-east-2"
	}
}
