# Lab 3: Drift Detection

![Terraform](https://img.shields.io/badge/Terraform-Drift_Detection-7B42BC?style=flat&logo=terraform)

## Objetivo
Detectar y reconciliar *configuration drift*: cuando la infraestructura real diverge del codigo Terraform por cambios manuales.

## Duracion
25 minutos

## Prerrequisitos
- Labs 1 y 2 del modulo 07 completados
- Terraform instalado

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
mkdir -p /root/lab
cd /root/lab
```

```bash
mkdir -p config scripts
```

Separar archivos de configuracion y scripts en subdirectorios facilita la organizacion y refleja una estructura realista de un proyecto.

### Paso 2: Crear la infraestructura base

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

resource "local_file" "app_config" {
  filename = "${path.module}/config/app.conf"
  content  = <<-EOT
    # Configuracion de la aplicacion
    entorno=produccion
    version=2.0
    max_conexiones=100
    timeout=30
  EOT
}

resource "local_file" "deploy_script" {
  filename        = "${path.module}/scripts/deploy.sh"
  content         = "#!/bin/bash\necho 'Desplegando version 2.0'\n"
  file_permission = "0755"
}

resource "local_file" "hosts" {
  filename = "${path.module}/config/hosts.txt"
  content  = "web-01 10.0.1.10\nweb-02 10.0.1.11\n"

  lifecycle {
    ignore_changes = [content]
  }
}

output "archivos" {
  value = [
    local_file.app_config.filename,
    local_file.deploy_script.filename,
    local_file.hosts.filename,
  ]
}
EOF
```

`app_config` y `deploy_script` son gestionados completamente por Terraform. `hosts` usa `lifecycle { ignore_changes = [content] }` para representar un archivo que otra herramienta (como Ansible) puede modificar sin que Terraform lo revierta.

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

```bash
cat config/app.conf
```

```bash
terraform plan
```

El primer `terraform plan` debe mostrar `No changes` — el state coincide exactamente con los archivos en disco.

### Paso 3: Introducir drift manual

```bash
printf '\n# MODIFICADO MANUALMENTE\ndebug=true\n' >> config/app.conf
```

```bash
printf "echo 'Paso adicional aniadido manualmente'\n" >> scripts/deploy.sh
```

```bash
printf 'db-01 10.0.2.10\n' >> config/hosts.txt
```

Estos comandos simulan cambios manuales hechos directamente en el sistema de archivos, sin pasar por Terraform. En entornos reales esto ocurre cuando alguien edita configuraciones de emergencia directamente en el servidor.

### Paso 4: Detectar el drift con terraform plan

```bash
terraform plan
```

Terraform compara el state almacenado con la realidad actual en disco. Los recursos `app_config` y `deploy_script` apareceran como `~ update in-place` porque su contenido cambio. `hosts` no aparecera gracias a `ignore_changes = [content]`.

### Paso 5: Documentar las opciones de reconciliacion

```bash
touch opciones-reconciliacion.md
```

```bash
cat > opciones-reconciliacion.md <<'EOF'
# Opciones para reconciliar el drift

## Opcion 1: Revertir el drift — el codigo es la fuente de verdad
Ejecutar terraform apply para sobreescribir los cambios manuales con el codigo.
Usar cuando: los cambios manuales fueron un error o son temporales.

## Opcion 2: Adoptar el drift — actualizar el codigo para reflejar la realidad
Editar main.tf para incluir los cambios deseados, luego ejecutar terraform apply.
Usar cuando: los cambios manuales son validos y deben mantenerse.

## Opcion 3: Ignorar campos especificos — ignore_changes
Agregar lifecycle { ignore_changes = [campo] } para que Terraform no revierta
ese campo especifico.
Usar cuando: otro sistema (Ansible, scripts de init) gestiona ese campo.

## Comandos utiles para diagnostico
terraform plan               # detecta drift comparando state vs realidad
terraform plan -refresh-only # solo actualiza el state, no modifica recursos
terraform state show <recurso>   # inspecciona un recurso del state
EOF
```

Documentar las opciones de reconciliacion ayuda al equipo a elegir la estrategia correcta segun el contexto. La eleccion incorrecta puede resultar en perdida de datos o configuracion invalida.

### Paso 6: Revertir el drift con terraform apply

```bash
terraform apply -auto-approve
```

```bash
cat config/app.conf
```

```bash
terraform plan
```

`terraform apply` sobreescribe los cambios manuales con el contenido definido en el codigo. `app.conf` vuelve a su estado original. El segundo `terraform plan` debe mostrar `No changes`.

### Paso 7: Verificar que ignore_changes protege el archivo hosts

```bash
printf 'db-01 10.0.2.10\n' >> config/hosts.txt
```

```bash
terraform plan
```

```bash
terraform plan -refresh-only
```

El archivo `hosts.txt` tiene contenido diferente al registrado en el state, pero `ignore_changes = [content]` le dice a Terraform que ignore esa diferencia. El plan no muestra cambios para `local_file.hosts`. `terraform plan -refresh-only` actualiza el state para reflejar la realidad sin ejecutar cambios.

### Paso 8: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. Infraestructura creada con estado limpio
2. Drift introducido manualmente en al menos un recurso
3. `terraform plan` detecto el drift
4. Drift revertido con `terraform apply`
5. `ignore_changes` aplicado en al menos un recurso
6. `opciones-reconciliacion.md` creado

## Prevenir el drift en CI/CD

```bash
# En un pipeline de CI, ejecutar plan periodicamente.
# El exit code 2 significa que hay cambios (drift detectado).
terraform plan -detailed-exitcode
# exit 0 = sin cambios
# exit 1 = error
# exit 2 = hay cambios planificados
```

## Conceptos Aprendidos

- Que es configuration drift y por que ocurre
- `terraform plan` como herramienta de deteccion
- Opciones de reconciliacion: revertir vs adoptar vs ignorar
- `ignore_changes` para campos gestionados externamente
- `terraform plan -refresh-only` para actualizar el state sin modificar recursos

---

**Anterior:** [Lab 2 - Upgrades](../lab2-upgrades/)
**Siguiente:** [Lab 4 - Troubleshooting](../lab4-troubleshooting/)
