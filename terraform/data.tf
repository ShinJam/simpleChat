###################################
# Cloud Init
###################################
# Jenkins
data "template_file" "jenkins_userdata" {
  template = file("templates/userdata/jenkins_ec2.sh")
}

#
#data "template_cloudinit_config" "init_jenkins" {
#  # https://stackoverflow.com/questions/62067211/how-to-pass-multiple-template-files-to-user-data-variable-in-terraform
#  # TODO: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
#  gzip          = false
#  base64_encode = false
#
#  part {
#    content_type = "text/x-shellscript"
#    filename     = "userdata.sh"
#    content      = data.template_file.jenkins_userdata.rendered
#  }
#}

# API Server
data "template_file" "api_userdata" {
  template = file("templates/userdata/api_ec2.sh")
}

#data "cloudinit_config" "init_api_server" {
#  # https://stackoverflow.com/questions/62067211/how-to-pass-multiple-template-files-to-user-data-variable-in-terraform
#  # TODO: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
#  gzip          = false
#  base64_encode = false
#
#  part {
#    content_type = "text/x-shellscript"
#    filename     = "userdata.sh"
#    content      = data.template_file.api_userdata.rendered
#  }
#}

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

# EC2 - Jenkins, api-server
data "aws_iam_policy_document" "ssm" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParametersByPath",
      "ssm:StartSession",
      "ssm:TerminateSession"
    ]

    resources = [
      "*", # only ecr:GetAuthorizationToken allow resources all("*")
      #      "arn:aws:ssm:ap-northeast-2:*",
    ]
  }
}

