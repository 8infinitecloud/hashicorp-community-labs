# Lab 4: Troubleshooting

![Terraform](https://img.shields.io/badge/Terraform-Troubleshooting-7B42BC?style=flat&logo=terraform)

## Objetivo
Diagnosticar y resolver errores comunes de Terraform usando `terraform validate`, logs de debug con `TF_LOG`, e inspeccion del state.

## Duracion
30 minutos

## Prerrequisitos
- Labs 1, 2 y 3 del modulo 07 completados
- Terraform instalado

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
mkdir -p /root/lab
cd /root/lab
```

### Paso 2: Crear un archivo con errores intencionales

```bash
touch main-con-errores.tf
```

```bash
cat > main-con-errores.tf <<'EOF'
# main-con-errores.tf — CONTIENE ERRORES INTENCIONALES

terraform {
  required_version = ">= 1.0"
}

variable "entorno" {
  type    = string
  default = "dev
  # ERROR 1: string no cerrada — falta la comilla de cierre
}

resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "entorno=${var.entorno}\n"
  permisos = "0644"
  # ERROR 2: atributo "permisos" no existe — el correcto es "file_permission"
}

resource "local_file" "dependiente" {
  filename = "${path.module}/dep.txt"
  content  = local_file.no_existe.filename
  # ERROR 3: referencia a recurso que no existe en la configuracion
}
EOF
```

El archivo tiene tres errores clasicos: una cadena sin cerrar, un atributo con nombre incorrecto, y una referencia a un recurso inexistente. Estos son los errores mas frecuentes al escribir HCL por primera vez.

### Paso 3: Usar terraform validate para detectar los errores

```bash
terraform init
```

```bash
terraform validate 2>&1
```

`terraform validate` analiza la sintaxis y las referencias sin conectarse a ningun provider. Muestra cada error con el numero de linea y una descripcion. Nota que el Error 1 puede ocultar los errores posteriores hasta que se corrija.

### Paso 4: Crear main.tf con los errores corregidos

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

variable "entorno" {
  type    = string
  default = "dev"              # FIX 1: string cerrada correctamente
}

resource "local_file" "config" {
  filename        = "${path.module}/config.txt"
  content         = "entorno=${var.entorno}\n"
  file_permission = "0644"    # FIX 2: nombre correcto del atributo
}

resource "local_file" "dependiente" {
  filename = "${path.module}/dep.txt"
  content  = local_file.config.filename   # FIX 3: referencia a recurso existente
}
EOF
```

Cada correccion resuelve exactamente un error: cerrar la cadena, usar el nombre de atributo correcto segun la documentacion del provider, y referenciar un recurso que si existe en la configuracion.

```bash
rm main-con-errores.tf
```

```bash
terraform validate
```

```bash
terraform apply -auto-approve
```

`terraform validate` debe pasar sin errores. Luego `terraform apply` crea los dos archivos en disco.

### Paso 5: Usar TF_LOG para ver logs de debug

```bash
TF_LOG=DEBUG terraform plan 2>&1 | head -50
```

`TF_LOG=DEBUG` activa el modo verbose de Terraform. La salida incluye informacion sobre la inicializacion del provider, llamadas al plugin y resolusion de referencias. `head -50` limita la salida para no inundar la terminal.

```bash
TF_LOG=DEBUG TF_LOG_PATH=/root/lab/terraform-debug.log terraform plan
```

`TF_LOG_PATH` redirige los logs a un archivo en lugar de stderr. Esto es util en CI/CD para guardar evidencia de ejecuciones.

```bash
head -60 /root/lab/terraform-debug.log
```

Niveles de log disponibles: `TRACE` (mas verboso), `DEBUG`, `INFO`, `WARN`, `ERROR` (menos verboso). Para depurar problemas de provider usar `TRACE`; para monitoreo general usar `INFO`.

### Paso 6: Troubleshooting de state inconsistente

```bash
rm config.txt
```

```bash
terraform plan
```

Al borrar `config.txt` manualmente el state dice que existe pero no esta en disco. `terraform plan` detecta la divergencia y muestra que quiere recrear el archivo.

```bash
terraform apply -auto-approve
```

```bash
terraform plan
```

`terraform apply` recrea el archivo eliminado. El segundo `terraform plan` vuelve a mostrar `No changes`. Esta es la forma correcta de resolver un state inconsistente: dejar que Terraform reconcilie.

### Paso 7: Usar terraform plan -out y terraform show

```bash
terraform plan -out=/root/lab/tfplan
```

```bash
terraform show /root/lab/tfplan
```

```bash
terraform apply /root/lab/tfplan
```

`terraform plan -out=tfplan` guarda el plan en un archivo binario. `terraform apply tfplan` aplica exactamente ese plan, sin posibilidad de que algo cambie entre el plan y el apply. Esta es la practica recomendada en CI/CD para garantizar que lo que se reviso es lo que se aplica.

```bash
rm /root/lab/tfplan
```

### Paso 8: Documentar errores comunes

```bash
touch errores-comunes.md
```

```bash
cat > errores-comunes.md <<'EOF'
# Errores Comunes de Terraform y sus Soluciones

## 1. "Error acquiring the state lock"
Causa: otro proceso tiene el lock activo (apply interrumpido, crash).
Solucion: esperar a que termine. Si el proceso ya no existe:
  terraform force-unlock <LOCK_ID>

## 2. "Error: Inconsistent dependency lock file"
Causa: .terraform.lock.hcl no coincide con los providers instalados.
Solucion: terraform init -upgrade

## 3. "Error: Reference to undeclared resource"
Causa: referencia a un recurso que no existe en el codigo.
Solucion: verificar el tipo y nombre del recurso referenciado.

## 4. "Error: Unsupported argument"
Causa: atributo con nombre incorrecto para ese tipo de recurso.
Solucion: consultar la documentacion del provider en registry.terraform.io.

## 5. "Error: Invalid string literal"
Causa: cadena sin cerrar o caracter especial sin escapar.
Solucion: revisar las comillas y heredocs en el archivo .tf.

## 6. "Error: Cycle detected"
Causa: dependencia circular entre recursos (A depende de B, B depende de A).
Solucion: usar depends_on explicito o reestructurar las referencias.

## 7. "Error: Provider produced inconsistent result after apply"
Causa: bug en el provider o configuracion incorrecta.
Solucion: actualizar el provider con terraform init -upgrade.

## 8. "Permission denied"
Causa: Terraform no tiene permisos para crear o modificar el recurso.
Solucion: verificar credenciales y permisos del usuario/rol.
EOF
```

Un catalogo de errores comunes acelera el diagnostico en el futuro. En equipos grandes este archivo se convierte en la primera referencia antes de escalar el problema.

### Paso 9: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. Errores de sintaxis identificados con `terraform validate`
2. `main.tf` corregido: usa `file_permission` y referencias validas
3. `terraform validate` pasa sin errores
4. Estado aplicado (`terraform.tfstate` existe)
5. Log de debug generado en `terraform-debug.log`
6. `errores-comunes.md` creado con contenido sustancial

## Referencia rapida de comandos de debug

```bash
terraform validate
```

```bash
TF_LOG=DEBUG terraform plan 2>&1 | head -100
```

```bash
TF_LOG=DEBUG TF_LOG_PATH=debug.log terraform apply
```

```bash
terraform state list
```

```bash
terraform state show local_file.config
```

```bash
terraform apply -replace=local_file.config
```

## Conceptos Aprendidos

- `terraform validate` para errores de sintaxis y referencias
- `TF_LOG` con niveles TRACE/DEBUG/INFO/WARN/ERROR
- `TF_LOG_PATH` para guardar logs en archivo
- Errores comunes y sus soluciones
- `terraform plan -out` y `terraform apply <planfile>`
- `terraform apply -replace` para forzar recreacion de un recurso

---

**Anterior:** [Lab 3 - Drift Detection](../lab3-drift-detection/)
**Siguiente:** [Modulo 08 - HCP Terraform](../../08-hcp-terraform/)
