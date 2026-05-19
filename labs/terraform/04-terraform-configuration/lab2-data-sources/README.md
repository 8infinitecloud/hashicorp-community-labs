# Lab 2: Data Sources

![Terraform](https://img.shields.io/badge/Terraform-DataSources-7B42BC?style=flat&logo=terraform)

## Objetivo

Consultar datos externos o recursos existentes usando data sources del provider `local`. Entender la diferencia entre un recurso (`resource`) y una fuente de datos (`data`), y usar los datos leídos para generar archivos de configuración derivados.

## Duración

30 minutos

## Prerrequisitos

- Lab 1 completado
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab/output
```

El directorio `output/` almacenará los archivos que Terraform crea y los que leerá como data sources. Mantenerlos separados de los archivos `.tf` facilita la inspección.

### Paso 2: Crear main.tf con el Provider

```bash
touch /root/lab/main.tf
```

```bash
cat > /root/lab/main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
EOF
```

El bloque `terraform` fija la versión mínima de Terraform y declara los providers necesarios. El provider `local` permite crear y leer archivos en el sistema de archivos del host.

### Paso 3: Crear resources.tf — Archivos de Origen

```bash
touch /root/lab/resources.tf
```

```bash
cat > /root/lab/resources.tf <<'EOF'
# Crear un archivo JSON de configuracion que luego leeremos con un data source
resource "local_file" "app_config" {
  filename = "/root/lab/output/app-config.json"
  content = jsonencode({
    app_name    = "MyApp"
    version     = "1.0.0"
    environment = "production"
    port        = 8080
  })
}

# Crear archivos de configuracion por entorno
resource "local_file" "env_dev" {
  filename = "/root/lab/output/env-dev.json"
  content = jsonencode({
    environment = "dev"
    replicas    = 1
    memory      = "512Mi"
  })
}

resource "local_file" "env_staging" {
  filename = "/root/lab/output/env-staging.json"
  content = jsonencode({
    environment = "staging"
    replicas    = 2
    memory      = "1Gi"
  })
}

resource "local_file" "env_prod" {
  filename = "/root/lab/output/env-prod.json"
  content = jsonencode({
    environment = "prod"
    replicas    = 5
    memory      = "2Gi"
  })
}
EOF
```

Estos `local_file` son los recursos que Terraform creará y gestionará. En un escenario real representarían recursos de nube que ya existen; aquí los creamos nosotros para poder leerlos después con data sources.

### Paso 4: Crear data-sources.tf — Leer Datos con Data Sources

```bash
touch /root/lab/data-sources.tf
```

```bash
cat > /root/lab/data-sources.tf <<'EOF'
# Leer el archivo JSON creado en resources.tf
# depends_on garantiza que el archivo exista antes de intentar leerlo
data "local_file" "read_config" {
  filename   = local_file.app_config.filename
  depends_on = [local_file.app_config]
}

# Decodificar el JSON leido y guardarlo en un local para reutilizarlo
locals {
  config_data = jsondecode(data.local_file.read_config.content)
}

# Leer el archivo del entorno de produccion
data "local_file" "prod_config" {
  filename   = local_file.env_prod.filename
  depends_on = [local_file.env_prod]
}

locals {
  prod_data = jsondecode(data.local_file.prod_config.content)
}
EOF
```

Un `data` block no crea ni destruye nada: solo lee información ya existente y la expone como atributos. La referencia `data.local_file.read_config.content` funciona igual que `local_file.app_config.content`, pero proviene de una lectura en tiempo de plan.

### Paso 5: Crear derived.tf — Archivos Derivados a Partir de los Data Sources

```bash
touch /root/lab/derived.tf
```

```bash
cat > /root/lab/derived.tf <<'EOF'
# Generar un resumen usando los datos leidos con el data source
resource "local_file" "app_info" {
  filename = "/root/lab/output/app-info.txt"
  content  = <<-EOT
    Application : ${local.config_data.app_name}
    Version     : ${local.config_data.version}
    Environment : ${local.config_data.environment}
    Port        : ${local.config_data.port}
  EOT
}

# Generar un manifiesto de deployment usando los datos de produccion
resource "local_file" "deployment" {
  filename = "/root/lab/output/deployment.yaml"
  content  = <<-EOT
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ${local.config_data.app_name}
    spec:
      replicas: ${local.prod_data.replicas}
      template:
        spec:
          containers:
          - name: app
            image: ${local.config_data.app_name}:${local.config_data.version}
            ports:
            - containerPort: ${local.config_data.port}
            resources:
              limits:
                memory: ${local.prod_data.memory}
  EOT
}

# Crear tres copias del config usando count
resource "local_file" "config_copies" {
  count    = 3
  filename = "/root/lab/output/config-copy-${count.index}.txt"
  content  = "Copy ${count.index}: ${local.config_data.app_name} v${local.config_data.version}"
}
EOF
```

Los recursos en `derived.tf` dependen implícitamente de los data sources a través de los `locals`. Terraform los crea en el orden correcto sin necesidad de `depends_on` explícito.

### Paso 6: Crear outputs.tf

```bash
touch /root/lab/outputs.tf
```

```bash
cat > /root/lab/outputs.tf <<'EOF'
output "app_name" {
  description = "Nombre de la aplicacion leido desde el data source"
  value       = local.config_data.app_name
}

output "app_version" {
  description = "Version leida desde el data source"
  value       = local.config_data.version
}

output "prod_replicas" {
  description = "Replicas de produccion leidas desde el data source"
  value       = local.prod_data.replicas
}

output "config_file_id" {
  description = "ID (hash SHA1) del archivo de configuracion"
  value       = data.local_file.read_config.id
}
EOF
```

Los outputs exponen valores del estado de Terraform hacia el exterior. El atributo `id` de `local_file` es el hash SHA1 del contenido del archivo, útil para detectar cambios.

### Paso 7: Inicializar y Aplicar

```bash
terraform -chdir=/root/lab init
```

```bash
terraform -chdir=/root/lab apply -auto-approve
```

Terraform ejecuta primero los `resource` para crear los archivos, luego lee los `data` sources, y finalmente crea los recursos derivados. Observa el orden en la salida del apply.

### Paso 8: Verificar Outputs y Estado

```bash
terraform -chdir=/root/lab output
```

```bash
terraform -chdir=/root/lab state list
```

`terraform output` imprime los valores declarados en `outputs.tf`. `state list` muestra tanto los recursos (`local_file.*`) como los data sources (`data.local_file.*`) registrados en el estado.

### Paso 9: Inspeccionar un Data Source en el Estado

```bash
terraform -chdir=/root/lab state show data.local_file.read_config
```

Los data sources quedan registrados en el estado como `data.<tipo>.<nombre>`. Puedes inspeccionarlos igual que cualquier recurso para ver qué atributos leyeron.

### Paso 10: Verificar los Archivos Generados

```bash
ls /root/lab/output/
```

```bash
cat /root/lab/output/app-info.txt
```

```bash
cat /root/lab/output/deployment.yaml
```

El archivo `app-info.txt` contiene valores tomados del JSON original a través del data source. `deployment.yaml` combina datos de dos data sources distintos en un único archivo de salida.

### Paso 11: Ir al Directorio del Lab

```bash
cd /root/lab
```

### Paso 12: Ejecutar la Validación

```bash
bash validate-lab.sh
```

## Conceptos

| Concepto | Descripcion |
|---|---|
| `data` block | Lee información de recursos existentes sin crearlos ni destruirlos |
| `data.<tipo>.<nombre>.<atributo>` | Sintaxis para referenciar un atributo de un data source |
| `depends_on` en data source | Garantiza que el dato existe antes de intentar leerlo; necesario cuando el dato lo crea el mismo plan |
| `jsondecode()` | Convierte una cadena JSON en un objeto HCL que puede referenciarse con notación de punto |
| `locals` | Valores intermedios calculados una sola vez y reutilizables en todo el módulo |
| `id` en `local_file` | Hash SHA1 del contenido; cambia si el archivo cambia, lo que permite detectar drift |
| `output` | Expone valores del estado hacia el exterior; pueden ser consumidos por otros módulos o por el operador |

---

**Anterior:** [Lab 1 - Resources Lifecycle](../lab1-resources-lifecycle/)
**Siguiente:** [Lab 3 - Variables con Validacion](../lab3-variables-validacion/)
