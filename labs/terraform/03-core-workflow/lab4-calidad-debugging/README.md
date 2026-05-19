# Lab 4: Calidad de Codigo y Debugging

![Terraform](https://img.shields.io/badge/Terraform-Quality-7B42BC?style=flat&logo=terraform)

## Objetivo

Dominar las herramientas de calidad integradas en Terraform: `fmt` para formateo automático, `validate` para detección temprana de errores, `TF_LOG` para tracing detallado, y `terraform console` para evaluar expresiones interactivamente. Al finalizar el lab, el código pasará `fmt -check` y `validate` sin errores.

## Duración

30 minutos

## Prerrequisitos

- Lab 3 completado
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Crear la Estructura del Proyecto

```bash
mkdir -p /root/lab
```

El directorio `/root/lab` aloja la configuración, el state y los logs de este lab.

### Paso 2: Crear un Archivo Deliberadamente Mal Formateado

```bash
touch /root/lab/main.tf
```

```bash
cat > /root/lab/main.tf <<'EOF'
terraform{
required_version=">= 1.0"
required_providers{
local={
source="hashicorp/local"
version="~> 2.4"
}}}

resource "local_file" "app_config" {
filename="/root/lab/output/app.conf"
content="host=localhost\nport=8080\n"
}

resource "local_file" "env_file" {
filename="/root/lab/output/.env"
content="APP_ENV=development\nDEBUG=true\n"
}

variable "instance_count" {
type=number
default=1
}

output "config_path"{
value=local_file.app_config.filename
}
EOF
```

El archivo tiene formato incorrecto a propósito: sin espacios alrededor de `=`, sin indentación, llaves pegadas al nombre del bloque. Esto permite demostrar el efecto real de `terraform fmt`.

### Paso 3: Intentar Inicializar (Funciona Pese al Mal Formato)

```bash
terraform -chdir=/root/lab init
```

`terraform init` descarga providers y puede operar con código mal formateado porque el formateo es cosmético, no sintáctico. Esto confirma que `fmt` es un paso de calidad independiente de la ejecución.

### Paso 4: Verificar el Formato Antes de Corregir

```bash
terraform -chdir=/root/lab fmt -check
```

`fmt -check` devuelve exit code 1 y lista los archivos que no cumplen el estilo canónico, sin modificarlos. Es el modo apropiado para pipelines de CI/CD donde detectar el problema sin corregirlo automáticamente es el objetivo.

### Paso 5: Aplicar el Formateo Automatico

```bash
terraform -chdir=/root/lab fmt
```

`terraform fmt` reescribe `main.tf` en su lugar con el estilo correcto: indentación de dos espacios, espacios alrededor de `=`, llaves separadas del nombre del bloque. El comando imprime los nombres de los archivos que modificó.

### Paso 6: Confirmar que el Formato es Correcto

```bash
terraform -chdir=/root/lab fmt -check
```

Tras el formateo, `fmt -check` no debe producir salida y debe devolver exit code 0. Si hay salida, significa que algún archivo todavía no cumple el estilo.

### Paso 7: Validar la Configuracion

```bash
terraform -chdir=/root/lab validate
```

`terraform validate` analiza la semántica de la configuración: verifica que los tipos de las variables son correctos, que las referencias a otros recursos existen, y que los argumentos de cada recurso son válidos según el schema del provider. Debe mostrar `Success! The configuration is valid.`

### Paso 8: Habilitar Logging de Debug para un Plan

```bash
export TF_LOG=DEBUG
```

```bash
export TF_LOG_PATH=/root/lab/terraform-debug.log
```

Las variables de entorno `TF_LOG` y `TF_LOG_PATH` activan el sistema de logging de Terraform. `DEBUG` produce registros detallados de las llamadas al provider, la evaluación del plan y la actualización del state.

```bash
terraform -chdir=/root/lab plan
```

El plan se ejecuta normalmente en la terminal, pero también escribe todos los mensajes de debug en el archivo de log. Esto es invaluable para diagnosticar errores de autenticación, problemas de red o comportamientos inesperados del provider.

### Paso 9: Revisar los Logs Generados

```bash
wc -l /root/lab/terraform-debug.log
```

El archivo de log suele tener miles de líneas incluso para configuraciones simples. Ver el conteo de líneas ilustra por qué `TF_LOG=DEBUG` no se usa en ejecuciones normales.

```bash
grep -i "provider" /root/lab/terraform-debug.log | head -5
```

Filtrar el log por términos clave (como `provider`, `error`, `request`) permite extraer información relevante sin leer todo el archivo.

### Paso 10: Deshabilitar el Logging

```bash
unset TF_LOG
```

```bash
unset TF_LOG_PATH
```

Deshabilitar el logging evita que ejecuciones futuras generen archivos de log innecesarios. En entornos de producción, el logging se habilita puntualmente para diagnosticar un problema y se desactiva al terminar.

### Paso 11: Aplicar la Configuracion

```bash
terraform -chdir=/root/lab apply -auto-approve
```

Aplica la configuración validada y formateada, creando los dos archivos de salida. El apply es más confiable cuando viene precedido de `fmt` y `validate`.

### Paso 12: Explorar Expresiones con Terraform Console

```bash
terraform -chdir=/root/lab console <<'EOF'
local_file.app_config.filename
EOF
```

`terraform console` evalúa expresiones HCL contra el state actual sin modificar nada. Pasarle un heredoc ejecuta las expresiones en modo no interactivo, compatible con scripts.

```bash
terraform -chdir=/root/lab console <<'EOF'
upper("terraform")
EOF
```

Las funciones built-in de Terraform también son evaluables en console. `upper`, `lower`, `format`, `join`, `length` y muchas más permiten probar transformaciones de datos antes de usarlas en recursos.

```bash
terraform -chdir=/root/lab console <<'EOF'
var.instance_count + 10
EOF
```

Las variables declaradas en la configuración también son accesibles en console con su valor por defecto. Esto permite verificar expresiones que combinan variables y funciones.

### Paso 13: Limpiar los Recursos

```bash
terraform -chdir=/root/lab destroy -auto-approve
```

Elimina los archivos creados por el apply y deja el state vacío. Al finalizar un lab siempre se debe hacer destroy para no acumular recursos.

### Paso 14: Ejecutar la Validacion del Lab

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

El script verifica que Terraform está instalado, el directorio fue inicializado, `main.tf` existe y pasa `fmt -check` y `validate`, que se generó el archivo de log de debug, y que el estado final es coherente.

## Conceptos Clave

| Concepto | Descripcion |
|---|---|
| `terraform fmt` | Reescribe archivos `.tf` con el estilo canónico de HashiCorp |
| `terraform fmt -check` | Verifica formato sin modificar; exit code 1 si hay diferencias (ideal para CI) |
| `terraform validate` | Comprueba semántica: tipos, referencias y argumentos; no requiere credenciales |
| `TF_LOG=DEBUG` | Activa logging detallado; niveles: TRACE, DEBUG, INFO, WARN, ERROR |
| `TF_LOG_PATH` | Redirige los logs a un archivo en lugar de stderr |
| `terraform console` | REPL que evalúa expresiones HCL contra el state actual; no modifica nada |
| Orden recomendado | `fmt` → `validate` → `plan` → `apply`; detectar errores lo antes posible |
| Logging en CI/CD | Usar `TF_LOG=ERROR` por defecto; escalar a DEBUG solo en fallo |

---

**Anterior:** [Lab 3 - Destroy y Proteccion](../lab3-destroy-proteccion/)
**Siguiente:** [Modulo 4 - Terraform Configuration](../../04-terraform-configuration/)
