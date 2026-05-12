# ⚙️ GitHub Actions - Explicación del Pipeline

## ¿Qué es GitHub Actions?

**GitHub Actions** es un sistema de CI/CD (Integración Continua / Despliegue Continuo) integrado en GitHub. Permite automatizar tareas como:
- Compilar código
- Ejecutar pruebas
- Escanear seguridad
- Desplegar aplicaciones

---

## 📁 Estructura del Workflow

El archivo está en: `.github/workflows/sonarqube-pipeline.yml`

```yaml
name: 🛡️ SonarQube QA Infrastructure Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

### ¿Qué significa cada parte?

| Sección | Descripción |
|---------|-------------|
| `name` | Nombre que aparece en la pestaña "Actions" de GitHub |
| `on: push` | Se ejecuta cuando haces `git push` a main o develop |
| `on: pull_request` | Se ejecuta cuando creas un PR hacia main |
| `workflow_dispatch` | Permite ejecutar manualmente desde la UI |

---

## 🔄 Los 4 Jobs del Pipeline

### Job 1: 🔍 `validate-infra`

**¿Qué hace?**
Valida que la configuración de Terraform esté correcta.

**Pasos:**
1. **Checkout** - Descarga el código del repo
2. **Setup Terraform** - Instala Terraform 1.7.0
3. **Terraform Fmt** - Verifica que el formato sea correcto
4. **Terraform Init** - Inicializa Terraform (sin backend remoto)
5. **Terraform Validate** - Valida la sintaxis

**¿Por qué?**
Si hay errores de sintaxis en Terraform, no tiene sentido continuar.

**Cuándo falla?**
- Si hay errores de sintaxis en archivos `.tf`
- Si faltan variables requeridas

---

### Job 2: 🐳 `build-and-scan`

**¿Qué hace?**
Construye la imagen Docker y escanea vulnerabilidades de seguridad.

**Dependencia:** Solo corre si `validate-infra` termina bien.

**Pasos:**
1. **Checkout** - Descarga el código
2. **Build Docker Image** - Construye la imagen desde `docker/Dockerfile.sonarqube`
3. **Trivy Scan** - Escanea la imagen en busca de vulnerabilidades (CVE)
4. **Upload Report** - Guarda el reporte de seguridad como artefacto

**¿Por qué?**
- La imagen debe construirse correctamente
- Trivy busca vulnerabilidades conocidas en los paquetes instalados

**Herramientas usadas:**
- **Docker Build** - Construye la imagen
- **Trivy** - Escáner de vulnerabilidades de Aqua Security

**Cuándo falla?**
- Si el Dockerfile tiene errores
- Si hay vulnerabilidades críticas en la imagen

---

### Job 3: 🚀 `deploy`

**¿Qué hace?**
Aplica la infraestructura con Terraform.

**Dependencia:** Solo corre si `build-and-scan` termina bien.
**Condición:** Solo se ejecuta en la rama `main` (no en PRs).

**Pasos:**
1. **Checkout** - Descarga el código
2. **Setup Terraform** - Instala Terraform
3. **Terraform Init** - Inicializa (con backend si está configurado)
4. **Terraform Plan** - Muestra qué recursos se crearán
5. **Terraform Apply** - Crea/actualiza los recursos

**Variables de entorno:**
```bash
TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
```

**¿Por qué?**
- `terraform plan` muestra un preview de cambios
- `terraform apply` hace los cambios reales

**Cuándo falla?**
- Si los contenedores ya existen y hay conflictos
- Si hay problemas de permisos

---

### Job 4: ⚙️ `configure-quality-gates`

**¿Qué hace?**
Configura las reglas de calidad en SonarQube automáticamente.

**Dependencia:** Solo corre si `deploy` termina bien.
**Condición:** Solo se ejecuta en la rama `main`.

**Pasos:**
1. **Checkout** - Descarga el código
2. **Wait SonarQube** - Espera hasta que SonarQube esté listo (max 5 min)
3. **Create Quality Gate** - Crea un gate llamado "Strict-QA-Gate"
4. **Configure Conditions** - Agrega las condiciones:
   - Coverage < 80% → ERROR
   - blocker_violations > 0 → ERROR
   - vulnerabilities > 0 → ERROR
5. **Set as Default** - Lo establece como gate por defecto

**¿Por qué?**
- Automatiza la configuración que normalmente harías a mano
- Asegura que todos los proyectos tengan las mismas reglas

**API de SonarQube usada:**
```bash
curl -u ${{ secrets.SONAR_TOKEN }}: \
  -X POST "${{ secrets.SONAR_HOST_URL }}/api/qualitygates/create" \
  -d "name=Strict-QA-Gate"
```

---

## 🔀 Flujo de Ejecución

```
GitHub Actions

     │
     ▼
┌─────────────────┐
│ validate-infra  │ ──► Si falla, se detiene aquí
└────────┬────────┘
         │ ✓
         ▼
┌─────────────────┐
│ build-and-scan  │ ──► Si falla, se detiene aquí
└────────┬────────┘
         │ ✓
         ▼
┌─────────────────┐
│     deploy      │ ──► Solo en main
└────────┬────────┘
         │ ✓
         ▼
┌───────────────────────┐
│ configure-quality-gates│ ──► Solo en main
└───────────────────────┘
```

---

## 🖥️ Dónde se ejecuta el Pipeline

### Ejecutores (Runners)

GitHub proporciona **runners** (máquinas virtuales) para ejecutar los jobs:

| Runner | Sistema Operativo |
|--------|-------------------|
| `ubuntu-latest` | Ubuntu 22.04 (gratuito) |
| `windows-latest` | Windows Server 2022 |
| `macos-latest` | macOS Monterey |

Nosotros usamos `ubuntu-latest` que es gratuito.

### Recursos del Runner
- 2 cores de CPU
- 7 GB de RAM
- 14 GB de disco SSD

---

## 👁️ Cómo ver la ejecución

1. Ve a tu repo en GitHub
2. Click en **Actions** (pestaña superior)
3. Verás la lista de ejecuciones
4. Click en una ejecución para ver:
   - Status de cada job
   - Logs de cada paso
   - Tiempo de ejecución

---

## 🛠️ Personalizar el Pipeline

### Cambiar la versión de Terraform

```yaml
env:
  TERRAFORM_VERSION: "1.7.0"  # Cambia aquí
```

### Agregar más pasos de seguridad

```yaml
- name: Scan with SonarCloud
  uses: SonarSource/sonarcloud-github-action@master
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Cambiar los Quality Gates

Edita las condiciones en el Job 4:

```yaml
# Cambiar cobertura mínima de 80% a 70%
-d "error=70"  # en lugar de 80
```

---

## ✅ Resumen

| Job | Propósito | Cuándo falla |
|-----|-----------|--------------|
| `validate-infra` | Validar Terraform | Errores de sintaxis |
| `build-and-scan` | Build + Security | Dockerfile malo o vulnerabilidades |
| `deploy` | Crear infraestructura | Conflictos de recursos |
| `configure-quality-gates` | Configurar reglas | SonarQube no disponible |

---

## ➡️ Siguiente paso

Ir a: [Guía de Despliegue](./deployment-guide.md)