# Lab 3: Drift Detection

![Terraform](https://img.shields.io/badge/Terraform-Drift_Detection-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Detectar y reconciliar *configuration drift*: cuando la infraestructura real diverge del código Terraform por cambios manuales.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Labs 1 y 2 del módulo 07 completados
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear la Infraestructura Base

```bash
mkdir lab3-drift-detection
cd lab3-drift-detection
mkdir -p config scripts
```

Crea `main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"
}

resource "local_file" "app_config" {
  filename = "${path.module}/config/app.conf"
  content  = <<-EOT
    # Configuración de la aplicación
    entorno=produccion
    version=2.0
    max_conexiones=100
    timeout=30
  EOT
}

resource "local_file" "deploy_script" {
  filename        = "${path.module}/scripts/deploy.sh"
  content         = "#!/bin/bash\necho 'Desplegando versión 2.0'\n"
  file_permission = "0755"
}

resource "local_file" "hosts" {
  filename = "${path.module}/config/hosts.txt"
  content  = "web-01 10.0.1.10\nweb-02 10.0.1.11\n"
}

output "archivos" {
  value = [
    local_file.app_config.filename,
    local_file.deploy_script.filename,
    local_file.hosts.filename,
  ]
}
```

```bash
terraform init
terraform apply -auto-approve

# Verificar estado inicial
cat config/app.conf
terraform plan   # debe mostrar: No changes
```

### Paso 2: Introducir Drift Manual

```bash
# Simula cambios manuales que alguien hizo fuera de Terraform

# Cambio 1: modificar la configuración de la app
echo "# MODIFICADO MANUALMENTE" >> config/app.conf
echo "debug=true" >> config/app.conf

# Cambio 2: modificar el script de despliegue
echo "echo 'Paso adicional añadido manualmente'" >> scripts/deploy.sh

# Cambio 3: agregar un host no gestionado
echo "db-01 10.0.2.10" >> config/hosts.txt

echo "=== Cambios manuales aplicados ==="
cat config/app.conf
```

### Paso 3: Detectar el Drift con terraform plan

```bash
# Terraform detecta la divergencia comparando state vs realidad
terraform plan

# Observa:
# ~ local_file.app_config will be updated in-place (o replaced)
# ~ local_file.deploy_script will be updated in-place
# ~ local_file.hosts will be updated in-place
#
# Terraform quiere REVERTIR los cambios manuales al estado del código
```

### Paso 4: Entender las Opciones de Reconciliación

```bash
cat > opciones-reconciliacion.md << 'EOF'
# Opciones para reconciliar el drift

## Opción 1: Revertir el drift → aceptar el código como fuente de verdad
```
terraform apply   # sobreescribe los cambios manuales con el código
```
Usar cuando: Los cambios manuales fueron un error o son temporales.

## Opción 2: Adoptar el drift → actualizar el código para reflejar la realidad
Editar main.tf para incluir los cambios deseados,
luego ejecutar terraform apply.
Usar cuando: Los cambios manuales son válidos y deben mantenerse.

## Opción 3: Ignorar cambios específicos → ignore_changes
```hcl
resource "local_file" "app_config" {
  lifecycle {
    ignore_changes = [content]
  }
}
```
Usar cuando: Ciertos campos los gestiona otra herramienta (Ansible, etc.)
EOF

cat opciones-reconciliacion.md
```

### Paso 5: Opción A — Revertir con terraform apply

```bash
# Revertir todos los cambios manuales
terraform apply -auto-approve

# Verificar que el drift fue corregido
cat config/app.conf   # debe tener solo el contenido original
terraform plan        # debe mostrar: No changes
```

### Paso 6: Opción B — Adoptar el Drift con ignore_changes

Actualiza `main.tf` para ignorar cambios en el contenido del archivo de hosts:

```hcl
resource "local_file" "hosts" {
  filename = "${path.module}/config/hosts.txt"
  content  = "web-01 10.0.1.10\nweb-02 10.0.1.11\n"

  lifecycle {
    ignore_changes = [content]   # Ignora cambios manuales en el contenido
  }
}
```

```bash
# Introducir drift en hosts nuevamente
echo "db-01 10.0.2.10" >> config/hosts.txt

# Ahora el plan no detecta cambios en hosts
terraform plan

# El recurso hosts ya no aparece en el plan
```

### Paso 7: Terraform refresh — Actualizar el State

```bash
# terraform refresh actualiza el state para reflejar la realidad actual
# (sin modificar la infraestructura)
# Nota: refresh está integrado en plan/apply desde Terraform 1.x

# Ver el state antes del refresh
terraform state show local_file.hosts | grep content

# En versiones antiguas: terraform refresh
# En versiones modernas, el refresh ocurre automáticamente en plan/apply
terraform plan -refresh-only
```

### Paso 8: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Infraestructura creada con estado limpio
2. ✅ Drift introducido manualmente
3. ✅ `terraform plan` detecta el drift
4. ✅ Drift revertido con `terraform apply`
5. ✅ `ignore_changes` aplicado en al menos un recurso

## 💡 Prevenir el Drift

```bash
# Ejecutar terraform plan periódicamente en CI/CD
# Si hay drift: notificar al equipo

# Ejemplo con GitHub Actions:
# - name: Check for drift
#   run: terraform plan -detailed-exitcode
#   # exit code 2 = hay cambios (drift detectado)
```

## 🎓 Conceptos Aprendidos

- ✅ Qué es configuration drift y por qué ocurre
- ✅ `terraform plan` como herramienta de detección
- ✅ Opciones de reconciliación: revertir vs adoptar
- ✅ `ignore_changes` para campos gestionados externamente
- ✅ `terraform plan -refresh-only` para actualizar el state

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Drift Detection Badge**

---

**Anterior:** [Lab 2 - Upgrades](../lab2-upgrades/)
**Siguiente:** [Lab 4 - Troubleshooting](../lab4-troubleshooting/)
