# Lab 3: Destroy Selectivo y Proteccion de Recursos

![Terraform](https://img.shields.io/badge/Terraform-Protection-7B42BC?style=flat&logo=terraform)

## Objetivo

Demostrar cómo el meta-argumento `lifecycle { prevent_destroy = true }` protege recursos críticos contra destrucción accidental, practicar el destroy selectivo con `-target`, y aprender el procedimiento correcto para remover la protección cuando sea necesario.

## Duración

25 minutos

## Prerrequisitos

- Lab 2 completado
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab
```

Todos los archivos del lab se almacenarán bajo `/root/lab`. El state local también se creará aquí.

### Paso 2: Crear el Archivo de Configuración con Recursos Protegidos

```bash
touch /root/lab/main.tf
```

Crear el archivo vacío antes de escribir el contenido es una práctica que confirma que el directorio existe y tiene permisos de escritura.

```bash
cat > /root/lab/main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Recurso temporal: sin proteccion, puede destruirse libremente
resource "local_file" "temp_cache" {
  filename = "/root/lab/output/cache.tmp"
  content  = "cache temporal - puede eliminarse\n"
}

# Recurso de desarrollo: sin proteccion
resource "local_file" "dev_notes" {
  filename = "/root/lab/output/dev-notes.txt"
  content  = "Notas de desarrollo - puede eliminarse\n"
}

# Recurso critico: protegido contra destruccion accidental
resource "local_file" "production_config" {
  filename = "/root/lab/output/production.conf"
  content  = "ENV=production\nDB_HOST=db.example.com\nAPI_KEY=secret\n"

  lifecycle {
    prevent_destroy = true
  }
}

# Recurso critico: base de datos protegida
resource "local_file" "database_schema" {
  filename = "/root/lab/output/schema.sql"
  content  = "-- Schema de produccion\nCREATE TABLE users (id INT PRIMARY KEY);\n"

  lifecycle {
    prevent_destroy = true
  }
}

output "protected_files" {
  value = [
    local_file.production_config.filename,
    local_file.database_schema.filename,
  ]
}

output "unprotected_files" {
  value = [
    local_file.temp_cache.filename,
    local_file.dev_notes.filename,
  ]
}
EOF
```

Los bloques `lifecycle { prevent_destroy = true }` hacen que Terraform genere un error en tiempo de plan si cualquier operación intenta destruir esos recursos. Es una red de seguridad que protege contra `terraform destroy` accidental o targets equivocados.

### Paso 3: Inicializar y Aplicar Todos los Recursos

```bash
terraform -chdir=/root/lab init
```

Inicializa el provider `hashicorp/local` y prepara el directorio de trabajo.

```bash
terraform -chdir=/root/lab apply -auto-approve
```

Crea los cuatro recursos en disco. Tras el apply, el state registra todos ellos incluidos los dos protegidos.

```bash
terraform -chdir=/root/lab state list
```

Confirma que los cuatro recursos están en el state antes de continuar con los experimentos de destrucción.

### Paso 4: Destruir un Recurso No Protegido (Destroy Selectivo)

```bash
terraform -chdir=/root/lab destroy -target=local_file.temp_cache -auto-approve
```

`destroy -target` elimina únicamente `temp_cache`. Al no tener `prevent_destroy`, la operación tiene éxito sin errores. Este es el comportamiento esperado para recursos descartables.

```bash
terraform -chdir=/root/lab state list
```

El state ahora muestra tres recursos. `temp_cache` ha desaparecido; los demás permanecen intactos.

### Paso 5: Intentar Destruir un Recurso Protegido (Error Esperado)

```bash
terraform -chdir=/root/lab destroy -target=local_file.production_config -auto-approve
```

Este comando fallará con un error similar a: `Error: Instance cannot be destroyed — Resource local_file.production_config has lifecycle.prevent_destroy set`. El error es intencional: `prevent_destroy` cumple exactamente su propósito. No se destruye ningún recurso.

### Paso 6: Intentar un Destroy Total (Error Esperado)

```bash
terraform -chdir=/root/lab plan -destroy
```

`plan -destroy` calcula un plan de destrucción completa sin ejecutarlo. El plan también fallará porque incluye los recursos protegidos. Usar `-destroy` para revisar antes de ejecutar es una buena práctica; en este caso el error aparece en la fase segura de plan.

### Paso 7: Remover la Proteccion para Poder Destruir

```bash
cat > /root/lab/main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Recurso temporal: sin proteccion
resource "local_file" "temp_cache" {
  filename = "/root/lab/output/cache.tmp"
  content  = "cache temporal - puede eliminarse\n"
}

# Recurso de desarrollo: sin proteccion
resource "local_file" "dev_notes" {
  filename = "/root/lab/output/dev-notes.txt"
  content  = "Notas de desarrollo - puede eliminarse\n"
}

# Proteccion removida deliberadamente para limpiar el lab
resource "local_file" "production_config" {
  filename = "/root/lab/output/production.conf"
  content  = "ENV=production\nDB_HOST=db.example.com\nAPI_KEY=secret\n"
}

# Proteccion removida deliberadamente para limpiar el lab
resource "local_file" "database_schema" {
  filename = "/root/lab/output/schema.sql"
  content  = "-- Schema de produccion\nCREATE TABLE users (id INT PRIMARY KEY);\n"
}

output "protected_files" {
  value = [
    local_file.production_config.filename,
    local_file.database_schema.filename,
  ]
}

output "unprotected_files" {
  value = [
    local_file.temp_cache.filename,
    local_file.dev_notes.filename,
  ]
}
EOF
```

Remover los bloques `lifecycle` es el paso obligatorio antes de destruir un recurso protegido. Se requiere un `apply` para que el state refleje el cambio de metadatos antes de poder ejecutar el destroy.

```bash
terraform -chdir=/root/lab apply -auto-approve
```

El apply actualiza el state con la nueva configuración (sin `prevent_destroy`). Los archivos en disco no cambian porque el contenido es idéntico; solo cambian los metadatos de lifecycle.

### Paso 8: Destruir Todo al Finalizar el Lab

```bash
terraform -chdir=/root/lab destroy -auto-approve
```

Con la protección removida, `destroy` elimina los tres recursos restantes del state sin errores.

### Paso 9: Ejecutar la Validacion del Lab

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

El script verifica que Terraform está instalado, el directorio fue inicializado, `main.tf` contiene recursos `local_file`, que se usó `prevent_destroy` en algún punto del lab, y que la configuración final es válida.

## Conceptos Clave

| Concepto | Descripción |
|---|---|
| `lifecycle { prevent_destroy = true }` | Bloquea cualquier plan que intente destruir el recurso; error en fase de plan |
| Proteccion en tiempo de plan | El error por `prevent_destroy` ocurre antes de modificar infraestructura |
| Remover proteccion correctamente | Eliminar el bloque `lifecycle` + `apply` para actualizar metadatos en el state + `destroy` |
| `destroy -target` | Elimina un recurso especifico del state; falla si el recurso tiene `prevent_destroy` |
| `plan -destroy` | Calcula el plan de destruccion completa sin ejecutarlo; util para revisar impacto |
| Recursos criticos | Bases de datos, configuraciones de produccion, certificados: candidatos naturales a `prevent_destroy` |
| Limitaciones de `prevent_destroy` | No protege contra `terraform state rm` ni eliminacion manual fuera de Terraform |

---

**Anterior:** [Lab 2 - Targets Incremental](../lab2-targets-incremental/)
**Siguiente:** [Lab 4 - Calidad y Debugging](../lab4-calidad-debugging/)
