# Output group information
output "developer_group" {
  value       = aws_iam_group.developers.name
  description = "Developer group name"
}

output "operations_group" {
  value       = aws_iam_group.operations.name
  description = "Operations group name"
}

output "finance_group" {
  value       = aws_iam_group.finance.name
  description = "Finance group name"
}

output "analyst_group" {
  value       = aws_iam_group.analysts.name
  description = "Analyst group name"
}

# Output developer users
output "developer_users" {
  value       = aws_iam_user.dev_users[*].name
  description = "Developer user names"
}

# Output operations users
output "operations_users" {
  value       = aws_iam_user.ops_users[*].name
  description = "Operations user names"
}

# Output finance user
output "finance_user" {
  value       = aws_iam_user.finance_user.name
  description = "Finance user name"
}

# Output analyst users
output "analyst_users" {
  value       = aws_iam_user.analyst_users[*].name
  description = "Analyst user names"
}