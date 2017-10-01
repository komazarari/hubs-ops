terragrunt = {
  terraform {
    extra_arguments "conditional_vars" {
      commands = ["apply", "plan", "import", "push", "refresh", "destroy"]

      required_var_files = [
        "${get_parent_tfvars_dir()}/terraform.tfvars"
      ]
    }
  }

  remote_state {
    backend = "s3"

    config {
      bucket = "mr-dev.terraform"
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = "us-west-1"
      encrypt = true
      dynamodb_table = "mr-dev-terraform-lock"
    }
  }
}

shared = {
  region = "us-west-1"
  env = "dev"
  azs = "us-west-1a,us-west-1b"
  state_bucket = "mr-dev.terraform"
  dynamodb_table = "mr-dev-terraform-lock"
  describe_instances_policy = <<EOF
{

    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": "ec2:DescribeInstances",
          "Resource": "*"
      }
    ]
  }
  EOF
  ec2_role_policy = <<EOF
{

    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}