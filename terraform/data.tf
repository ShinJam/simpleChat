data "template_file" "userdata" {
  template = file("templates/jenkins/userdata.sh")
}

data "template_file" "install_jenkins" {
  template = file("templates/jenkins/install_package.sh")
}

data "cloudinit_config" "init_jenkins" {
  # https://stackoverflow.com/questions/62067211/how-to-pass-multiple-template-files-to-user-data-variable-in-terraform
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata.sh"
    content      = data.template_file.userdata.rendered
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "install_jenkins.sh"
    content      = data.template_file.install_jenkins.rendered
  }
}
###################################
# IAM Policies
###################################

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "get_params_by_path" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParametersByPath"
    ]

    resources = [
      "*", # only ecr:GetAuthorizationToken allow resources all("*")
#      "arn:aws:ssm:ap-northeast-2:*",
    ]
  }
}
