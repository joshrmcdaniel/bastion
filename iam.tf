resource "aws_iam_instance_profile" "bastion" {
  name = "BastionIP"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role" "bastion" {
  name               = "BastionRole"
  path               = "/ec2/"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
}

resource "aws_iam_policy" "bastion" {
  name        = "BastionPolicy"
  path        = "/ec2/"
  description = "Policy for bastion."

  policy = data.aws_iam_policy_document.bastion_perms.json
}

resource "aws_iam_policy_attachment" "bastion" {
  name       = "BastionPolicyAttachment"
  users      = []
  roles      = [aws_iam_role.bastion.name]
  groups     = []
  policy_arn = aws_iam_policy.bastion.arn
}

data "aws_iam_policy_document" "bastion_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bastion_perms" {
  statement {
    actions   = ["ssm:PutParameter", "ssm:GetParameter"]
    resources = [aws_ssm_parameter.wg_pubkey.arn]
  }
}
