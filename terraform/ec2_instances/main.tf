resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_ssm_role_assume_policy.json
}

resource "aws_iam_instance_profile" "ec2_ssm_role" {
  name = "ec2-ssm-role"
  path = "/"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_role_managed_instance" {
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_role_s3_read_only" {
  policy_arn = data.aws_iam_policy.s3_read_only.arn
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_instance" "inspector_instance" {
  ami           = data.aws_ami.latest_amazon_linux2.id
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_role.name
  tags = {
    Name = "InspectorInstance",
    ManagedBy = "Ansible",
    Playbook = "inspector-playbook.yml"
  }
}

resource "aws_instance" "yum_instance" {
  ami           = data.aws_ami.latest_amazon_linux2.id
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_role.name
  tags = {
    Name = "YumInstance",
    ManagedBy = "Ansible",
    Playbook = "yum-only-playbook.yml"
  }
}

