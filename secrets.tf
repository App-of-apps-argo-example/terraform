resource "aws_secretsmanager_secret" "db_password" {
  name                    = "microservice/db-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password_val" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    password = "SuperSecretEnterprisePassword123!"
  })
}
