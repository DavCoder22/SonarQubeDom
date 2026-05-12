# 🚀 Guía de Despliegue

Esta guía te muestra cómo levantar SonarQube localmente o en la nube.

---

## 📋 Prerrequisitos

### Software necesario

| Herramienta | Versión mínima | ¿Para qué? |
|-------------|----------------|-------------|
| **Docker** | 20.10+ | Contenedores |
| **Docker Compose** | 1.29+ | Orquestar servicios |
| **Git** | 2.30+ | Control de versiones |
| **Terraform** | 1.5+ | Infraestructura como Código |

### Verificar instalación

```bash
docker --version
docker-compose --version
git --version
terraform --version
```

---

## 🏠 Opción 1: Levantar con Docker Compose (Local)

### Paso 1: Clonar el repositorio

```bash
git clone https://github.com/DavCoder22/SonarQubeDom.git
cd SonarQubeDom
```

### Paso 2: Cambiar a la rama test

```bash
git checkout test
```

### Paso 3: Entrar a la carpeta docker

```bash
cd docker
```

### Paso 4: Levantar los servicios

```bash
docker-compose up -d
```

### Paso 5: Esperar a que SonarQube esté listo

```bash
# Ver el estado de los contenedores
docker-compose ps

# Ver logs de SonarQube (espera ~2-3 minutos)
docker-compose logs -f sonarqube
```

### Paso 6: Acceder a SonarQube

1. Abre tu navegador
2. Ve a: `http://localhost:9000`
3. Credenciales por defecto:
   - Usuario: `admin`
   - Password: `admin`

### Paso 7: Cambiar password

Se te pedirá cambiar el password en el primer login.

---

## 📊 Verificar que todo funciona

### Ver contenedores corriendo

```bash
$ docker-compose ps

NAME                IMAGE               STATUS
sonarqube-server    sonarqube:community  Up
sonarqube-postgres  postgres:15-alpine  Up
```

### Ver 健康 (Health Check)

```bash
# En el navegador, ve a:
http://localhost:9000/api/system/status

# Debería mostrar:
{"status":"UP"}
```

---

## 🧹 Comandos útiles

### Detener servicios

```bash
docker-compose down
```

### Detener y borrar datos

```bash
docker-compose down -v
# ⚠️ Esto borra todos los datos de SonarQube
```

### Ver logs

```bash
# Todos los servicios
docker-compose logs -f

# Solo SonarQube
docker-compose logs -f sonarqube

# Solo PostgreSQL
docker-compose logs -f sonarqube-postgres
```

### Reiniciar servicios

```bash
docker-compose restart
```

---

## 🏗️ Opción 2: Levantar con Terraform (Local)

### Paso 1: Instalar provider de Docker para Terraform

En Windows, esto requiere:
1. Instalar Docker Desktop
2. Habilitar "Expose daemon on tcp://localhost:2375" en Docker Desktop → Settings → General

### Paso 2: Inicializar Terraform

```bash
cd terraform
terraform init
```

### Paso 3: Ver el plan

```bash
terraform plan -var="db_password=sonar"
```

### Paso 4: Aplicar cambios

```bash
terraform apply -var="db_password=sonar"
```

### Paso 5: Ver outputs

```bash
terraform output

# Debería mostrar:
sonarqube_url = "http://localhost:9000"
```

---

## ☁️ Opción 3: Desplegar en la nube (AWS/GCP/Azure)

### Requisitos previos

1. Cuenta en proveedor cloud
2. Docker instalado en el servidor o usar servicio manejado

### AWS ECS (Ejemplo)

```hcl
# En terraform/main.tf, cambiar provider a AWS
provider "aws" {
  region = "us-east-1"
}

# Usar módulo de ECS en lugar de Docker local
module "ecs-sonarqube" {
  source = "./modules/ecs"
  # ...
}
```

### Google Cloud Run

```bash
# Construir y empujar imagen
docker build -t gcr.io/[PROJECT]/sonarqube:latest -f docker/Dockerfile.sonarqube .
docker push gcr.io/[PROJECT]/sonarqube:latest

# Desplegar
gcloud run deploy sonarqube \
  --image gcr.io/[PROJECT]/sonarqube:latest \
  --platform managed \
  --region us-central1
```

---

## 🔧 Configurar análisis de código

### 1. Crear proyecto en SonarQube

1. En SonarQube, click en **Projects** → **Create Project**
2. Nombre: `qa-framework-g2`
3. Click en **Set Up**

### 2. Generar token de análisis

1. Ve a **My Account** → **Security**
2. En "Generate Tokens":
   - Nombre: `qa-framework-analysis`
   - Tipo: **Analyzer**
3. Copia el token

### 3. Ejecutar análisis local

#### Opción A: Con SonarScanner CLI

```bash
# Descargar SonarScanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip sonar-scanner-cli-5.0.1.3006-linux.zip

# Ejecutar análisis
./sonar-scanner/bin/sonar-scanner \
  -Dsonar.projectKey=qa-framework-g2 \
  -Dsonar.sources=src \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=tu_token_aqui
```

#### Opción B: Con Maven (si es proyecto Java)

```bash
mvn clean verify sonar:sonar \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=tu_token_aqui
```

#### Opción C: Con Gradle (si es proyecto Gradle)

```bash
./gradlew sonarqube \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=tu_token_aqui
```

---

## 🚨 Solución de problemas

### Error: "Port 9000 already in use"

```bash
# Ver qué proceso usa el puerto
netstat -ano | findstr :9000

# O en Linux/Mac
lsof -i :9000

# Cambiar puerto en docker-compose.yml:
ports:
  - "9001:9000"  # Ahora accedes por localhost:9001
```

### Error: "PostgreSQL connection refused"

1. Verificar que PostgreSQL esté corriendo:
   ```bash
   docker-compose ps
   ```

2. Ver logs de PostgreSQL:
   ```bash
   docker-compose logs postgres
   ```

3. Aumentar tiempo de espera (PostgreSQL puede tardar en iniciar)

### SonarQube tarda mucho en iniciar

- La primera vez puede tomar **5-10 minutos**
- Ver progreso con:
  ```bash
  docker-compose logs -f sonarqube
  ```

### Error de memoria

Aumentar memoria en Docker Desktop:
- **Windows/Mac**: Docker Desktop → Settings → Resources → Memory → 4GB mínimo

---

## 📈 Próximos pasos

1. ✅ Levantar SonarQube
2. 🔄 Configurar análisis de código
3. 📊 Revisar métricas en el dashboard
4. ⚙️ Revisar Quality Gates

---

## 📞 Ayuda adicional

| Problema | Recurso |
|----------|---------|
| Documentación SonarQube | https://docs.sonarqube.org/ |
| Errores de Docker | `docker-compose logs` |
| Errores de Terraform | `terraform apply` muestra el error |
| Issues del repo | https://github.com/DavCoder22/SonarQubeDom/issues |

---

## 🎯 Checklist de despliegue

- [ ] Docker instalado y corriendo
- [ ] Puerto 9000 disponible
- [ ] `docker-compose up -d` exitoso
- [ ] SonarQube responde en http://localhost:9000
- [ ] Login con admin/admin funciona
- [ ] Proyecto creado en SonarQube
- [ ] Token de análisis generado
- [ ] Primer análisis ejecutado