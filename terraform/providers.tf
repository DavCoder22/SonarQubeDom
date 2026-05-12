# =============================================================================
# TERRAFORM - CONFIGURACIÓN DE PROVIDERS
# Define qué plugins de Terraform necesitamos
# =============================================================================

terraform {
  # Versión mínima de Terraform requerida
  required_version = ">= 1.5.0"
  
  # Providers necesarios
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  
  # =============================================================================
  # BACKEND REMOTO (descomenta para producción con S3)
  # Almacena el estado de forma segura y compartida
  # =============================================================================
  # backend "s3" {
  #   bucket         = "mi-terraform-state-bucket"
  #   key            = "sonarqube/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

# =============================================================================
# PROVIDER: Docker
# Conecta con el daemon de Docker local (o remoto)
# =============================================================================
provider "docker" {
  host = "unix:///var/run/docker.sock"
}