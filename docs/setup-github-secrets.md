# 🔐 Configurar Secrets en GitHub

## ¿Qué son los Secrets?

Los **Secrets** son variables cifradas que se almacenan en GitHub y se usan en los workflows de GitHub Actions. Son necesarios para:
- Proteger contraseñas y tokens
- No exponer credenciales en el código
- Permitir que los pipelines accedan a servicios externos

---

## 🛠️ Paso 1: Configurar Secrets del Repositorio

### 1.1 Acceder a la configuración

1. Ve a tu repositorio: `https://github.com/DavCoder22/SonarQubeDom`
2. Haz clic en **Settings** (Configuración)
3. En el menú izquierdo, busca **Secrets and variables** → **Actions**

### 1.2 Crear los Secrets necesarios

Crea los siguientes secrets (haz clic en "New repository secret"):

| Secret Name | Valor | ¿Para qué? |
|-------------|-------|------------|
| `SONAR_HOST_URL` | `http://localhost:9000` | URL donde corre SonarQube |
| `SONAR_TOKEN` | (ver abajo) | Token de autenticación con SonarQube |
| `DB_PASSWORD` | `sonar` | Password de PostgreSQL |

---

## 🔑 Cómo obtener el SONAR_TOKEN

### Opción A: Si tienes SonarQube local corriendo

1. Ve a `http://localhost:9000`
2. Inicia sesión (admin / admin)
3. Click en tu avatar (arriba derecha) → **My Account**
4. Click en **Security** (izquierda)
5. En "Generate Tokens":
   - Nombre: `github-actions-token`
   - Click en **Generate**
6. **COPIA EL TOKEN** (solo se muestra una vez)
7. Pégalo en el secret `SONAR_TOKEN` de GitHub

### Opción B: Crear token desde API (si no tienes acceso web)

```bash
# Ejecutar en la máquina donde corre SonarQube
curl -X POST "http://localhost:9000/api/user_tokens/generate" \
  -u admin:admin \
  -d "name=github-actions-token"
```

---

## ⚠️ Importante: Configurar GitHub Runner

### Si usas SonarQube desde tu máquina local

Los GitHub Actions corren en servidores de GitHub (no en tu PC). Para que puedan acceder a tu SonarQube local, tienes dos opciones:

### Opción 1: Usar GitHub Codespaces (Recomendado para pruebas)

1. En tu repo, ve a **Code** → **Codespaces**
2. Click en **Create codespace**
3. Codespace crea una VM con Docker instalado
4. El workflow puede usar esa VM para desplegar SonarQube localmente

### Opción 2: Desplegar SonarQube en un servidor accesible

1. Despliega SonarQube en un servidor (AWS, GCP, Azure, o servidor físico)
2. Usa la URL pública del servidor para `SONAR_HOST_URL`
3. Ejemplo: `https://sonarqube.tudominio.com`

### Opción 3: Usar SonarCloud (sin infraestructura propia)

1. Ve a `https://sonarcloud.io`
2. Inicia sesión con tu cuenta de GitHub
3. Crea un proyecto desde tu repositorio
4. El host URL será: `https://sonarcloud.io`
5. Genera un token en SonarCloud (no en SonarQube local)

---

## 📋 Resumen de Secrets a crear

```
SONAR_HOST_URL  = http://localhost:9000  (o tu URL pública)
SONAR_TOKEN     = tu_token_generado_en_sonar
DB_PASSWORD     = sonar
```

---

## ✅ Verificar que los secrets funcionan

Los secrets se usan en el workflow `.github/workflows/sonarqube-pipeline.yml`:

```yaml
- name: Run SonarQube Scan
  env:
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

Cuando hagas un push a la rama `main` o `develop`, el workflow usará estos valores automáticamente.

---

## 🔍 Solución de problemas

| Error | Causa | Solución |
|-------|-------|----------|
| `Connection refused` | SonarQube no está corriendo | Asegúrate de tener `docker-compose up -d` corriendo |
| `Authentication failed` | Token incorrecto | Genera un nuevo token en SonarQube |
| `Host unreachable` | Runner no reacha tu IP | Usa URL pública o SonarCloud |

---

## ➡️ Siguiente paso

Ir a: [Configurar GitHub Actions](./github-actions.md)