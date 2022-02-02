resource "aws_iam_role" "default_role" {
  name = "default-ec2-role"
  tags = local.common_tags

  assume_role_policy = data.aws_iam_policy_document.default.json
}

# Jenkins
resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-ec2-profile"
  role = aws_iam_role.default_role.name
  tags = local.common_tags
}

resource "aws_iam_role_policy" "main" {
  name   = "jenkins-ec2-policy"
  role   = aws_iam_role.default_role.id
  policy = data.aws_iam_policy_document.ssm.json
}


resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.default_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# API Server
resource "aws_iam_instance_profile" "api-server" {
  name = "api-server-ec2-profile"
  role = aws_iam_role.default_role.name
  tags = local.common_tags
}
