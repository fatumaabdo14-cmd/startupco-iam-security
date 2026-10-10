# startupco level 3: Require mfa for all users
resource "aws_iam_policy" "Require_mfa" {
  name        = "Require_mfa"
  description = "deny all actions except mfa self-setup unless signed in with mfa"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice",
          "iam:ChangePassword",
          "iam:GetUser",
        ]
        Resource = [
          "arn:aws:iam::*:user/$${aws:username}",
          "arn:aws:iam::*:mfa/$${aws:username}",
        ]
      },
      {
        Sid       = "DenyAllWithoutMFA"
        Effect    = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice",
          "iam:ChangePassword",
          "iam:GetUser",
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}
resource "aws_iam_group_policy_attachment" "developer_mfa" {
    group  = aws_iam_group.developers.name
    policy_arn = aws_iam_policy.Require_mfa.arn

}
resource "aws_iam_group_policy_attachment" "operations_mfa" {
    group  = aws_iam_group.operations.name
    policy_arn = aws_iam_policy.Require_mfa.arn
}
resource "aws_iam_group_policy_attachment" "finance_mfa"{
    group = aws_iam_group.finance.name
    policy_arn = aws_iam_policy.Require_mfa.arn

}
resource "aws_iam_group_policy_attachment" "analyst_mfa"{
    group = aws_iam_group.analysts.name
    policy_arn = aws_iam_policy.Require_mfa.arn
}
