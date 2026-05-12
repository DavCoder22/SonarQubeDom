# =============================================================================
# TERRAFORM - MÓDULO SONARQUBE
# Variables configurables para reutilización
# =============================================================================

# -----------------------------------------------------------------------------
# Variable: Nombre de la red Docker
# -----------------------------------------------------------------------------
variable "network_name" {
  description = "Nombre de la red Docker para comunicación entre contenedores"
  type        = string
  default     = "sonarqube-qa-network"
}

# -----------------------------------------------------------------------------
# Variable: Versión de SonarQube
# -----------------------------------------------------------------------------
variable "sonarqube_version" {
  description = "Tag de la imagen Docker de SonarQube (community, developer, enterprise)"
  type        = string
  default     = "community"
}

# -----------------------------------------------------------------------------
# Variable: Password de PostgreSQL
# SENSIBLE: Se debe pasar via variable de entorno o vault, NUNCA en código
# -----------------------------------------------------------------------------
variable "db_password" {
  description = "Password para la base de datos PostgreSQL de SonarQube"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Variables: Límites de recursos del contenedor
# -----------------------------------------------------------------------------
variable "cpu_limit" {
  description = "Límite de CPUs para SonarQube"
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Límite de memoria para SonarQube (ej: 2048m, 2g)"
  type        = string
  default     = "2048m"
}