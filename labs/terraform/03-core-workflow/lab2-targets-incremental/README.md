# Lab 2: Targets y Apply Incremental

![Terraform](https://img.shields.io/badge/Terraform-Targeting-7B42BC?style=flat&logo=terraform)

## Objetivo

Usar la bandera `-target` de Terraform para aplicar y destruir recursos individuales de forma incremental, observar cómo Terraform respeta automáticamente las dependencias, y entender cuándo es apropiado usar targets versus un apply completo.

## Duración

25 minutos

## Prerrequisitos

- Lab 1 completado
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab
```

El directorio `/root/lab` almacenará la configuración y el state de este lab. Usar una ruta fija facilita la validación automática al final.

### Paso 2: Crear el Archivo de Configuración

```bash
touch /root/lab/main.tf
```

Crear el archivo antes de escribir contenido es una práctica que hace explícita la intención y facilita la detección de errores de permisos.

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

# Recurso A: configuracion base (sin dependencias)
resource "local_file" "base_config" {
  filename = "/root/lab/output/base.conf"
  content  = "env=lab\nversion=1.0\n"
}

# Recurso B: depende de A (referencia a su filename)
resource "local_file" "app_config" {
  filename = "/root/lab/output/app.conf"
  content  = "base_config=${local_file.base_config.filename}\napp=web\n"
}

# Recurso C: log de auditoria (depende de B)
resource "local_file" "audit_log" {
  filename = "/root/lab/output/audit.log"
  content  = "app_config=${local_file.app_config.filename}\nstatus=active\n"
}

# Recurso D: resumen (sin dependencias de A/B/C)
resource "local_file" "summary" {
  filename = "/root/lab/output/summary.txt"
  content  = "Lab: targets-incremental\nRecursos: 4\n"
}

output "all_files" {
  value = [
    local_file.base_config.filename,
    local_file.app_config.filename,
    local_file.audit_log.filename,
    local_file.summary.filename,
  ]
}
EOF
```

La configuración define cuatro recursos con una cadena de dependencias: `base_config` <- `app_config` <- `audit_log`, más `summary` independiente. Esta estructura permite demostrar cómo `-target` arrastra dependencias automáticamente.

### Paso 3: Inicializar y Verificar la Sintaxis

```bash
terraform -chdir=/root/lab init
```

Descarga el provider `hashicorp/local` y crea `.terraform/`. Siempre es el primer paso antes de cualquier operación.

```bash
terraform -chdir=/root/lab validate
```

Confirma que las referencias entre recursos son válidas antes de invertir tiempo en un plan.

### Paso 4: Aplicar Solo el Recurso Independiente (Target Individual)

```bash
terraform -chdir=/root/lab apply -target=local_file.summary -auto-approve
```

`-target=local_file.summary` le indica a Terraform que solo gestione ese recurso. Como `summary` no tiene dependencias, se crea solo ese archivo. El state queda con un único recurso registrado.

```bash
terraform -chdir=/root/lab state list
```

La lista del state mostrará únicamente `local_file.summary`, confirmando que los otros tres recursos no fueron tocados.

### Paso 5: Aplicar un Recurso con Dependencias (Target con Cadena)

```bash
terraform -chdir=/root/lab apply -target=local_file.app_config -auto-approve
```

Aunque solo se especifica `local_file.app_config`, Terraform detecta que depende de `local_file.base_config` y lo incluye automáticamente en el plan. Las dependencias nunca se omiten, incluso con `-target`.

```bash
terraform -chdir=/root/lab state list
```

Ahora el state tendrá tres recursos: `base_config`, `app_config` y `summary`. El `audit_log` todavía no existe porque no fue solicitado ni es dependencia de los targets usados.

### Paso 6: Completar la Infraestructura con Apply Total

```bash
terraform -chdir=/root/lab apply -auto-approve
```

Un apply sin `-target` reconcilia toda la configuración con el state: crea el único recurso faltante (`audit_log`) y no toca los que ya existen. Este es el uso habitual de Terraform; `-target` es la excepción, no la regla.

```bash
terraform -chdir=/root/lab state list
```

Los cuatro recursos deben aparecer en la lista, confirmando que el state está completo.

### Paso 7: Destruir un Recurso Específico con Target

```bash
terraform -chdir=/root/lab destroy -target=local_file.summary -auto-approve
```

`destroy -target` elimina únicamente el recurso indicado, siempre que ningún otro recurso en el state dependa de él. `summary` es independiente, por lo que se elimina sin efectos secundarios.

```bash
terraform -chdir=/root/lab state list
```

El state debe mostrar los tres recursos restantes: `base_config`, `app_config` y `audit_log`.

### Paso 8: Destruir Todo lo que Queda

```bash
terraform -chdir=/root/lab destroy -auto-approve
```

`terraform destroy` sin target elimina todos los recursos registrados en el state, en el orden inverso de dependencias: primero `audit_log`, luego `app_config`, finalmente `base_config`.

### Paso 9: Ejecutar la Validación del Lab

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

El script verifica que Terraform está instalado, que el directorio fue inicializado, que `main.tf` contiene al menos cuatro recursos con la estructura correcta, y que el workflow de targets fue ejecutado.

## Conceptos Clave

| Concepto | Descripción |
|---|---|
| `-target=TIPO.NOMBRE` | Restringe plan/apply/destroy a un recurso específico |
| Dependencia implícita | Referencia a un atributo de otro recurso; Terraform infiere el orden de creación |
| Cadena de dependencias | Si A <- B <- C, un target sobre C incluye B y A automáticamente |
| Apply total | Apply sin `-target` reconcilia toda la configuración; uso habitual recomendado |
| Destroy selectivo | `destroy -target` elimina un recurso sin afectar al resto del state |
| State parcial | Resultado de usar targets repetidamente; puede quedar inconsistente si no se completa con apply total |
| Uso apropiado de targets | Debugging, recuperación puntual o primeros deploys incrementales controlados |

---

**Anterior:** [Lab 1 - Workflow Completo](../lab1-workflow-completo/)
**Siguiente:** [Lab 3 - Destroy y Proteccion](../lab3-destroy-proteccion/)
