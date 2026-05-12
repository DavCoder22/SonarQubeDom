# =============================================================================
# TERRAFORM - MÓDULO SONARQUBE
# Infraestructura como Código para desplegar SonarQube con Docker
# =============================================================================

# -----------------------------------------------------------------------------
# RECURSO 1: Red Docker privada
# Permite que los contenedores se comuniquen por nombre DNS interno
# -----------------------------------------------------------------------------
resource "docker_network" "sonarqube" {
  name   = var.network_name
  driver = "bridge"
}

# -----------------------------------------------------------------------------
# RECURSO 2: Volúmenes persistentes para datos
# -----------------------------------------------------------------------------
resource "docker_volume" "sonarqube_data" {
  name = "sonarqube_data"
}

resource "docker_volume" "sonarqube_extensions" {
  name = "sonarqube_extensions"
}

resource "docker_volume" "sonarqube_logs" {
  name = "sonarqube_logs"
}

resource "docker_volume" "postgresql_data" {
  name = "postgresql_data"
}

# -----------------------------------------------------------------------------
# RECURSO 3: Contenedor PostgreSQL
# Base de datos requerida por SonarQube para persistir métricas
# -----------------------------------------------------------------------------
resource "docker_container" "sonarqube_db" {
  name  = "sonarqube-postgres"
  image = "postgres:15-alpine"
  
  # Variables de entorno para inicializar PostgreSQL
  env = [
    "POSTGRES_USER=sonar",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=sonarqube"
  ]
  
  # Conectar a la red privada
  networks_advanced {
    name = docker_network.sonarqube.name
  }
  
  # Montar volumen persistente
  volumes {
    volume_name    = docker_volume.postgresql_data.name
    container_path = "/var/lib/postgresql/data"
  }
  
  # Política de reinicio: siempre que no se detenga manualmente
  restart = "unless-stopped"
  
  # Límites de recursos
  resources {
    memory = var.memory_limit
    cpu    = var.cpu_limit
  }
}

# -----------------------------------------------------------------------------
# RECURSO 4: Contenedor SonarQube
# Depende de que PostgreSQL esté creado primero
# -----------------------------------------------------------------------------
resource "docker_container" "sonarqube" {
  name  = "sonarqube-server"
  image = "sonarqube:${var.sonarqube_version}"
  
  # Dependencia explícita: esperar a PostgreSQL
  depends_on = [docker_container.sonarqube_db]
  
  # Exponer puerto 9000 al host
  ports {
    internal = 9000
    external = 9000
  }
  
  # Variables de entorno para conectar a PostgreSQL
  env = [
    "SONAR_JDBC_URL=jdbc:postgresql://sonarqube-postgres:5432/sonarqube",
    "SONAR_JDBC_USERNAME=sonar",
    "SONAR_JDBC_PASSWORD=${var.db_password}",
    "SONAR_WEB_JAVAOPTS=-Xmx512m -Xms128m",
    "SONAR_CE_JAVAOPTS=-Xmx512m -Xms128m",
    "SONAR_SEARCH_JAVAOPTS=-Xmx512m -Xms512m"
  ]
  
  # Conectar a la red privada
  networks_advanced {
    name = docker_network.sonarqube.name
  }
  
  # Múltiples volúmenes persistentes
  volumes {
    volume_name    = docker_volume.sonarqube_data.name
    container_path = "/opt/sonarqube/data"
  }
  
  volumes {
    volume_name    = docker_volume.sonarqube_extensions.name
    container_path = "/opt/sonarqube/extensions"
  }
  
  volumes {
    volume_name    = docker_volume.sonarqube_logs.name
    container_path = "/opt/sonarqube/logs"
  }
  
  # Política de reinicio
  restart = "unless-stopped"
  
  # Límites de recursos
  resources {
    memory = var.memory_limit
    cpu    = var.cpu_limit
  }
  
  # Health check: verificar que SonarQube responde
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:9000/api/system/status"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}