resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-ec2-profile"
  role = aws_iam_role.jenkins_role.name
  tags = local.common_tags
}

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy" "main" {
  name   = "jenkins-ec2-policy"
  role   = aws_iam_role.jenkins_role.id
  policy = data.aws_iam_policy_document.get_params_by_path.json
}
