# Lab 4: Idempotencia, Drift y State

## Objetivo

Comprobar en la práctica tres principios de IaC: la idempotencia (aplicar dos veces no cambia nada), la detección de drift (cambios hechos fuera de Terraform) y el rol del state como mapa entre tu código y los recursos reales.

## Duración

25 minutos

## Prerrequisitos

- Labs 1, 2 y 3 del Módulo 1 completados
- Terraform instalado (verificar con `terraform version`)

## Escenario

Gestionas la configuración de un servidor web con Terraform. Un compañero edita un archivo a mano "solo para probar" y otro borra un archivo por error. Verás cómo Terraform detecta esos cambios y devuelve todo al estado definido en el código.

## Instrucciones

### Paso 1: Crear el directorio del proyecto

```bash
mkdir lab4-drift-demo
```

Crea el directorio de trabajo del lab.

```bash
cd lab4-drift-demo
```

Entra al directorio para que todos los comandos siguientes operen dentro de él.

### Paso 2: Crear el archivo main.tf

```bash
cat > main.tf <<'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

variable "puerto" {
  description = "Puerto del servidor web"
  type        = number
  default     = 8080
}

resource "local_file" "web_config" {
  filename = "servidor/web.conf"
  content  = <<-EOT
    [servidor]
    nombre = "web-01"
    puerto = ${var.puerto}
    tls    = false
  EOT
}

resource "local_file" "inventario" {
  filename = "servidor/inventario.txt"
  content  = "web-01 -> puerto ${var.puerto}\n"
}

output "archivos" {
  value = [local_file.web_config.filename, local_file.inventario.filename]
}
EOF
```

Define dos recursos: la configuración del servidor y un inventario. Ambos dependen de la variable `puerto`.

### Paso 3: Inicializar y aplicar

```bash
terraform init
```

Descarga el provider `hashicorp/local`.

```bash
terraform apply -auto-approve
```

Crea los dos archivos dentro de `servidor/` y registra ambos recursos en `terraform.tfstate`.

### Paso 4: Comprobar la idempotencia

```bash
terraform apply -auto-approve
```

Aplica otra vez sin cambiar nada. Terraform compara el código con el state y la realidad, no encuentra diferencias y responde `No changes`. Aplicar N veces produce el mismo resultado.

```bash
terraform plan -detailed-exitcode; echo "Exit code: $?"
```

Con `-detailed-exitcode`, el plan devuelve `0` cuando no hay cambios, `2` cuando hay cambios pendientes y `1` si hay un error. Es la forma de detectar drift en un pipeline de CI.

### Paso 5: Inspeccionar el state

```bash
terraform state list
```

Lista las direcciones de los recursos que Terraform gestiona: `local_file.inventario` y `local_file.web_config`.

```bash
terraform state show local_file.web_config
```

Muestra los atributos que Terraform guardó de ese recurso. El state es el mapa entre `local_file.web_config` en tu código y el archivo real en disco.

### Paso 6: Provocar drift con un cambio manual

```bash
echo 'puerto = 9999' >> servidor/web.conf
```

Simula a alguien que edita el servidor a mano, fuera de Terraform.

```bash
terraform plan
```

Terraform detecta que el archivo ya no coincide con lo que registró y propone volver a crearlo (`Plan: 1 to add`). Eso es el drift: la realidad se alejó del código.

### Paso 7: Corregir el drift

```bash
terraform apply -auto-approve
```

Terraform vuelve a dejar el archivo como dice el código.

```bash
cat servidor/web.conf
```

La línea `puerto = 9999` desapareció. En IaC el código es la fuente de verdad: los cambios manuales se pierden en el siguiente apply.

### Paso 8: Recuperar un recurso borrado

```bash
rm servidor/inventario.txt
```

Simula que alguien borra un recurso por error.

```bash
terraform plan
```

El plan muestra `local_file.inventario will be created`: el recurso sigue en el código y en el state, pero ya no existe en la realidad.

```bash
terraform apply -auto-approve
```

Terraform lo vuelve a crear, sin pasos manuales.

### Paso 9: Cambiar el código

```bash
sed -i 's/default     = 8080/default     = 8081/' main.tf
```

Ahora el cambio se hace en el código, que es la forma correcta: el puerto por defecto pasa a `8081`.

```bash
terraform plan
```

Observa el símbolo `-/+` y el texto `# forces replacement`: cambiar el contenido de un `local_file` obliga a destruir y recrear el recurso. En otros recursos verás `~` (cambio in-place).

```bash
terraform apply -auto-approve
```

Aplica el cambio. Verifica con `cat servidor/web.conf` que ahora dice `puerto = 8081`.

### Paso 10: Confirmar que no hay drift

```bash
terraform plan -detailed-exitcode; echo "Exit code: $?"
```

Debe devolver `0`: el código, el state y la realidad coinciden.

```bash
ls terraform.tfstate*
```

Verás `terraform.tfstate` y, normalmente, `terraform.tfstate.backup`. Con el backend local, el state vive en el directorio de trabajo y Terraform guarda una copia de una versión anterior en el archivo `.backup`.

### Paso 11: Volver al directorio del lab y validar

```bash
cd /root/lab
```

Regresa al directorio raíz del lab donde se encuentra el script de validación. No destruyas la infraestructura: el script revisa los archivos generados.

```bash
bash validate-lab.sh
```

Ejecuta las verificaciones automáticas del lab.

## Conceptos

| Concepto | Descripcion |
|---|---|
| Idempotencia | Aplicar la misma configuración varias veces produce el mismo resultado (`No changes`) |
| Drift | Diferencia entre la infraestructura real y lo definido en el código, por cambios hechos fuera de Terraform |
| `terraform plan -detailed-exitcode` | Exit code `0` sin cambios, `2` con cambios, `1` con error |
| `terraform state list` | Lista las direcciones de los recursos del state |
| `terraform state show` | Muestra los atributos de un recurso del state |
| `-/+` en el plan | El recurso se destruye y se vuelve a crear (`forces replacement`) |
| `terraform.tfstate.backup` | Copia de una versión anterior del state en el backend local |

---

**Anterior:** [Lab 3 - Infraestructura Local](../lab3-infraestructura-local/)
**Siguiente:** [Modulo 2 - Terraform Fundamentals](../../02-terraform-fundamentals/)
