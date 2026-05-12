# =============================================================================
# TERRAFORM - VARIABLES GLOBALES
# =============================================================================

variable "db_password" {
  description = "Password para PostgreSQL (pasar via TF_VAR_db_password o prompt)"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "sonarqube_version" {
  description = "Versión de SonarQube a desplegar"
  type        = string
  default     = "community"
}

variable "cpu_limit" {
  description = "Límite de CPU para los contenedores"
  type        = number
  default     = 2
}

variable "memory_limit" {
  description = "Límite de memoria para los contenedores (en MB)"
  type        = number
  default     = 2048
}