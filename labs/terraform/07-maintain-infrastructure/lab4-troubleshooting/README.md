# Lab 4: Troubleshooting

![Terraform](https://img.shields.io/badge/Terraform-Troubleshooting-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Diagnosticar y resolver errores comunes de Terraform usando logs de debug, `validate`, y técnicas de inspección del state.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Labs 1, 2 y 3 del módulo 07 completados
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Configuración con Errores Intencionales

```bash
mkdir lab4-troubleshooting
cd lab4-troubleshooting
```

Crea `main-con-errores.tf` — **este archivo tiene errores a propósito**:

```hcl
# main-con-errores.tf — CONTIENE ERRORES INTENCIONALES

terraform {
  required_version = ">= 1.0"
}

variable "entorno" {
  type    = string
  default = "dev
  # ERROR 1: string no cerrada
}

resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "entorno=${var.entorno}\n"
  permisos = "0644"
  # ERROR 2: atributo "permisos" no existe — es "file_permission"
}

resource "local_file" "dependiente" {
  filename = "${path.module}/dep.txt"
  content  = local_file.no_existe.filename
  # ERROR 3: referencia a recurso que no existe
}
```

### Paso 2: Usar terraform validate para Detectar Errores

```bash
# validate detecta errores de sintaxis y referencias sin conectar a la nube
terraform validate 2>&1

# Analiza los errores uno a uno
# Error 1: "Invalid string literal" → falta comilla de cierre
# Error 2: "Unsupported argument" → atributo incorrecto
# Error 3: "Reference to undeclared resource"
```

### Paso 3: Corregir Errores

Crea `main.tf` corregido:

```hcl
# main.tf — versión corregida

terraform {
  required_version = ">= 1.0"
}

variable "entorno" {
  type    = string
  default = "dev"            # FIX 1: string cerrada
}

resource "local_file" "config" {
  filename        = "${path.module}/config.txt"
  content         = "entorno=${var.entorno}\n"
  file_permission = "0644"   # FIX 2: nombre correcto del atributo
}

resource "local_file" "dependiente" {
  filename = "${path.module}/dep.txt"
  content  = local_file.config.filename  # FIX 3: referencia existente
}
```

```bash
# Eliminar el archivo con errores
rm main-con-errores.tf

terraform validate     # debe pasar sin errores
terraform init
terraform apply -auto-approve
```

### Paso 4: Habilitar Logs de Debug con TF_LOG

```bash
# Niveles de log: TRACE, DEBUG, INFO, WARN, ERROR
# TRACE es el más verboso

# Ver logs en terminal
TF_LOG=DEBUG terraform plan 2>&1 | head -40

# Guardar logs en archivo
TF_LOG=DEBUG TF_LOG_PATH=./terraform-debug.log terraform plan
cat terraform-debug.log | head -60

# Solo errores
TF_LOG=ERROR terraform plan 2>&1

# Desactivar logs
unset TF_LOG
```

### Paso 5: Troubleshoot con State

```bash
# Recurso "corrompido" — simular state inconsistente
# Borrar un archivo que Terraform cree que existe
rm config.txt

# Ahora el state dice que config.txt existe, pero no está en disco
# Plan detectará la divergencia
terraform plan   # verás que quiere recrear el archivo

# Solución: dejar que terraform lo recree
terraform apply -auto-approve

# O si queremos eliminar del state sin tocar el disco:
# terraform state rm local_file.config
```

### Paso 6: Errores Comunes y sus Soluciones

```bash
cat > errores-comunes.md << 'EOF'
# Errores Comunes de Terraform

## 1. "Error acquiring the state lock"
**Causa:** Otro proceso tiene el lock activo
**Solución:**
- Esperar a que termine
- Si el proceso no existe: terraform force-unlock <ID>

## 2. "Error: Inconsistent dependency lock file"
**Causa:** .terraform.lock.hcl no coincide con providers instalados
**Solución:** terraform init -upgrade

## 3. "Error: Reference to undeclared resource"
**Causa:** Referencia a un recurso que no existe en el código
**Solución:** Verificar el nombre del recurso y el tipo

## 4. "Error: Invalid value for input variable"
**Causa:** Tipo de variable incorrecto
**Solución:** Revisar el tipo declarado en variables.tf

## 5. "Error: Cycle: X → Y → X"
**Causa:** Dependencia circular entre recursos
**Solución:** Usar depends_on o reestructurar las referencias

## 6. "Error: No changes. Your infrastructure matches the configuration."
No es un error — significa que todo está actualizado

## 7. "Error: Provider produced inconsistent result after apply"
**Causa:** Bug en el provider o configuración incorrecta
**Solución:** Actualizar el provider, reportar el bug

## 8. "Permission denied"
**Causa:** Terraform no tiene permisos para crear/modificar recursos
**Solución:** Verificar credenciales y permisos IAM/cloud
EOF

cat errores-comunes.md
```

### Paso 7: Plan con Output Detallado

```bash
# Ver plan detallado con cambios por atributo
terraform plan -out=tfplan

# Inspeccionar el plan guardado
terraform show tfplan

# Aplicar el plan guardado (garantiza que se aplica exactamente lo planeado)
terraform apply tfplan

# Limpiar
rm tfplan
```

### Paso 8: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Errores de sintaxis identificados con `terraform validate`
2. ✅ Errores corregidos en el código
3. ✅ `TF_LOG=DEBUG` usado para inspeccionar el plan
4. ✅ Log guardado en archivo
5. ✅ `terraform plan -out=tfplan` usado

## 🔧 Referencia Rápida de Comandos de Debug

```bash
# Validar sintaxis sin conectar al cloud
terraform validate

# Debug completo
TF_LOG=TRACE terraform plan 2>&1 | head -100

# Solo logs de providers
TF_LOG_PROVIDER=DEBUG terraform plan

# Guardar logs
TF_LOG=DEBUG TF_LOG_PATH=debug.log terraform apply

# Ver estado actual
terraform show

# Listar recursos en state
terraform state list

# Inspeccionar recurso específico
terraform state show <resource_address>

# Forzar recreación de un recurso
terraform taint <resource_address>    # deprecated en TF >= 1.x
terraform apply -replace=<resource>   # forma moderna
```

## 🎓 Conceptos Aprendidos

- ✅ `terraform validate` para errores de sintaxis y referencias
- ✅ `TF_LOG` con niveles TRACE/DEBUG/INFO/WARN/ERROR
- ✅ `TF_LOG_PATH` para guardar logs en archivo
- ✅ Errores comunes y sus soluciones
- ✅ `terraform plan -out` + `terraform apply <planfile>`
- ✅ `terraform apply -replace` para forzar recreación

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Troubleshooting Badge**

---

**Anterior:** [Lab 3 - Drift Detection](../lab3-drift-detection/)
**Siguiente:** [Módulo 08 - HCP Terraform](../../08-hcp-terraform/)
