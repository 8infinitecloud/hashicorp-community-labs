# Lab 1: Resources con Dependencias y Lifecycle

![Terraform](https://img.shields.io/badge/Terraform-Lifecycle-7B42BC?style=flat&logo=terraform)

## Objetivo

Gestionar dependencias entre recursos usando referencias implícitas y `depends_on`, y controlar el ciclo de vida de los recursos con las reglas `create_before_destroy`, `prevent_destroy`, `ignore_changes` y `replace_triggered_by` del bloque `lifecycle`.

## Duración

35 minutos

## Prerrequisitos

- Módulos 1, 2 y 3 completados
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab
```

Todos los archivos `.tf` del lab viven en `/root/lab`. Terraform trata cada directorio como una configuración independiente.

### Paso 2: Crear main.tf con Dependencias Implícitas

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

# Recurso base — no depende de nadie
resource "local_file" "database" {
  filename = "/root/lab/output/database.txt"
  content  = "PostgreSQL connection string"
}

# Dependencia implícita: referencia a local_file.database hace que Terraform
# cree database.txt antes que config.txt
resource "local_file" "config" {
  filename = "/root/lab/output/config.txt"
  content  = "Database file: ${local_file.database.filename}"
}

# Dependencia implícita en cadena: logs depende de config, config depende de database
resource "local_file" "logs" {
  filename = "/root/lab/output/logs.txt"
  content  = "Logging to: ${local_file.config.filename}"
}
EOF
```

Una dependencia implícita se crea automáticamente cuando el valor de un atributo hace referencia a otro recurso con la sintaxis `resource_type.name.attribute`. Terraform resuelve el orden de creación leyendo el grafo de dependencias.

### Paso 3: Crear depends-on.tf con Dependencias Explícitas

```bash
touch /root/lab/depends-on.tf
```

```bash
cat > /root/lab/depends-on.tf <<'EOF'
# setup y env no tienen dependencias — se crean en paralelo
resource "local_file" "setup" {
  filename = "/root/lab/output/setup.txt"
  content  = "Setup complete"
}

resource "local_file" "env" {
  filename = "/root/lab/output/env.txt"
  content  = "Environment: production"
}

# depends_on fuerza que app se cree después de setup y env
# aunque no haya referencias directas en el contenido
resource "local_file" "app" {
  filename = "/root/lab/output/app.txt"
  content  = "Application started"

  depends_on = [
    local_file.setup,
    local_file.env,
  ]
}

resource "local_file" "health" {
  filename = "/root/lab/output/health.txt"
  content  = "Health check: OK"

  depends_on = [local_file.app]
}
EOF
```

`depends_on` es para dependencias que no se expresan como referencia directa: por ejemplo cuando un recurso necesita que otro exista aunque no use ninguno de sus atributos. Úsalo con moderación; prefiere referencias implícitas siempre que sea posible.

### Paso 4: Crear lifecycle.tf con las Cuatro Reglas de Ciclo de Vida

```bash
touch /root/lab/lifecycle.tf
```

```bash
cat > /root/lab/lifecycle.tf <<'EOF'
# create_before_destroy: Terraform crea el reemplazo antes de destruir el original.
# Útil cuando el recurso no puede tener downtime.
resource "local_file" "web_server" {
  filename = "/root/lab/output/web-server.txt"
  content  = "Web Server v1.0"

  lifecycle {
    create_before_destroy = true
  }
}

# prevent_destroy: Terraform rechaza cualquier plan que destruya este recurso.
# Quita la regla antes de poder hacer terraform destroy.
resource "local_file" "database_critical" {
  filename = "/root/lab/output/database-critical.txt"
  content  = "CRITICAL DATABASE — DO NOT DELETE"

  lifecycle {
    prevent_destroy = true
  }
}

# ignore_changes: Terraform no planea cambios en los atributos listados,
# incluso si el valor en el código difiere del estado.
resource "local_file" "user_config" {
  filename = "/root/lab/output/user-config.txt"
  content  = "Initial config — may be modified externally"

  lifecycle {
    ignore_changes = [content]
  }
}

# replace_triggered_by: Terraform reemplaza este recurso si el recurso
# referenciado cambia, aunque sus propios atributos no hayan cambiado.
resource "local_file" "base_config" {
  filename = "/root/lab/output/base-config.txt"
  content  = "Base Config v1"
}

resource "local_file" "application" {
  filename = "/root/lab/output/application.txt"
  content  = "Application using base config"

  lifecycle {
    replace_triggered_by = [local_file.base_config]
  }
}
EOF
```

Cada regla de `lifecycle` modifica cuándo y cómo Terraform destruye o reemplaza un recurso. Son independientes entre sí y se pueden combinar en un mismo bloque.

### Paso 5: Crear el Directorio de Salida e Inicializar

```bash
mkdir -p /root/lab/output
```

```bash
terraform -chdir=/root/lab init
```

`terraform init` descarga el provider `hashicorp/local` y prepara el directorio `.terraform`. Debe ejecutarse una vez antes de cualquier otro comando de Terraform.

### Paso 6: Aplicar la Configuración

```bash
terraform -chdir=/root/lab apply -auto-approve
```

Terraform calcula el grafo de dependencias, determina el orden correcto de creación y ejecuta todos los recursos. Observa en la salida cómo `database.txt` se crea antes que `config.txt`, y `config.txt` antes que `logs.txt`.

### Paso 7: Verificar los Archivos Creados

```bash
ls /root/lab/output/
```

```bash
terraform -chdir=/root/lab state list
```

`state list` muestra todos los recursos que Terraform gestiona. Cada línea corresponde a un recurso en el estado y debe coincidir con los recursos definidos en los archivos `.tf`.

### Paso 8: Ver el Grafo de Dependencias

```bash
terraform -chdir=/root/lab graph
```

La salida en formato DOT describe el árbol de dependencias. Cada flecha indica que el recurso de origen debe existir antes que el de destino. Puedes pegar la salida en [Graphviz Online](https://dreampuf.github.io/GraphvizOnline/) para visualizarlo.

### Paso 9: Remover prevent_destroy para poder Destruir

```bash
cat > /root/lab/lifecycle.tf <<'EOF'
resource "local_file" "web_server" {
  filename = "/root/lab/output/web-server.txt"
  content  = "Web Server v1.0"

  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "database_critical" {
  filename = "/root/lab/output/database-critical.txt"
  content  = "CRITICAL DATABASE — DO NOT DELETE"
}

resource "local_file" "user_config" {
  filename = "/root/lab/output/user-config.txt"
  content  = "Initial config — may be modified externally"

  lifecycle {
    ignore_changes = [content]
  }
}

resource "local_file" "base_config" {
  filename = "/root/lab/output/base-config.txt"
  content  = "Base Config v1"
}

resource "local_file" "application" {
  filename = "/root/lab/output/application.txt"
  content  = "Application using base config"

  lifecycle {
    replace_triggered_by = [local_file.base_config]
  }
}
EOF
```

`prevent_destroy = true` protege el recurso en el código; para destruirlo hay que eliminar la regla primero y ejecutar `terraform apply` para actualizar el estado, luego `terraform destroy`.

### Paso 10: Destruir los Recursos

```bash
terraform -chdir=/root/lab apply -auto-approve
```

```bash
terraform -chdir=/root/lab destroy -auto-approve
```

`terraform destroy` elimina todos los recursos gestionados en orden inverso al de creación, respetando las dependencias. Si `prevent_destroy` sigue presente en algún recurso, el plan fallará con un error explícito.

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
| Dependencia implícita | Se crea automáticamente cuando un atributo referencia otro recurso (`resource_type.name.attr`) |
| `depends_on` | Fuerza un orden de creación sin necesidad de referenciar atributos del recurso dependido |
| `create_before_destroy` | Terraform crea el nuevo recurso antes de destruir el anterior durante un reemplazo |
| `prevent_destroy` | Impide que `terraform destroy` o cualquier plan destruya el recurso; es un error en tiempo de plan |
| `ignore_changes` | Terraform ignora las diferencias en los atributos listados y no planifica actualizaciones para ellos |
| `replace_triggered_by` | El recurso se reemplaza si el recurso (o atributo) referenciado cambia, aunque sus propios atributos no hayan cambiado |
| Grafo de dependencias | Estructura interna de Terraform que determina el orden de operaciones; visible con `terraform graph` |

---

**Anterior:** [Modulo 4 - Intro](../)
**Siguiente:** [Lab 2 - Data Sources](../lab2-data-sources/)
