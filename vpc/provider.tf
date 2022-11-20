terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 3.27"
      }
    }
}

/*Cloud info such as region*/
provider "aws" {
  profile = "default"
  region = "us-west-2"
}

