variable "aws_region" {
  description = "Region de AWS donde se desplegara la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "database_url" {
  description = "URL de conexion a PostgreSQL"
  type        = string
  sensitive   = true
}

variable "database_username" {
  description = "Usuario de PostgreSQL"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "Contrasena de PostgreSQL"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Secreto utilizado para firmar los JWT"
  type        = string
  sensitive   = true
}