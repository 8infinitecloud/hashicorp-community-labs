# Lab 1: Instalar Terraform

![Terraform](https://img.shields.io/badge/Terraform-Installation-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Instalar Terraform manualmente desde un zip pre-descargado, verificar que el binario funciona y completar el script de validación.

## ⏱️ Duración
15 minutos

## 📋 Prerrequisitos
- Contenedor Ubuntu activo (ya está corriendo)
- El zip de Terraform está en `/opt/downloads/` — no necesitas internet

## 🚀 Instrucciones Paso a Paso

### Paso 1: Verificar el zip disponible

El archivo de Terraform ya está descargado en el contenedor. Verifica que esté ahí:

```bash
ls /opt/downloads/
```

Deberías ver algo como: `terraform_1.9.5_linux_amd64.zip`

### Paso 2: Descomprimir el archivo

Extrae el binario de Terraform al directorio `/tmp/`:

```bash
unzip -o /opt/downloads/terraform_*.zip terraform -d /tmp/
```

### Paso 3: Instalar el binario en el PATH

Mueve el binario a `/usr/local/bin/` para que quede disponible en todo el sistema:

```bash
mv /tmp/terraform /usr/local/bin/
```

### Paso 4: Dar permisos de ejecución

```bash
chmod +x /usr/local/bin/terraform
```

### Paso 5: Verificar la instalación

Confirma que Terraform está correctamente instalado:

```bash
terraform version
```

Deberías ver algo como: `Terraform v1.9.5`

### Paso 6: Explorar los comandos disponibles

```bash
terraform -help
```

### Paso 7: Ejecutar el script de validación

```bash
bash /root/lab/validate-lab.sh
```

## ✅ Criterios de Validación

Para completar exitosamente este laboratorio:

1. ✅ Terraform instalado en `/usr/local/bin/terraform`
2. ✅ Comando `terraform version` funciona
3. ✅ Versión 1.0 o superior detectada
4. ✅ Terraform disponible en el PATH del sistema

## 🎓 Conceptos Aprendidos

- ✅ Instalación manual de un binario en Linux
- ✅ Uso del PATH del sistema (`/usr/local/bin/`)
- ✅ Verificación de herramientas CLI con `--version`

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Installation Badge**

---

**Siguiente:** [Lab 2 - Tu Primer Archivo Terraform](../lab2-primer-archivo/)
