# Lab Nomad: Deploy de Contenedor

![Nomad](https://img.shields.io/badge/Nomad-Practitioner-00CA8E?style=flat&logo=nomad)

## 🎯 Objetivo
Desplegar una aplicación web simple usando Nomad.

## ⏱️ Duración
10-15 minutos

## 📋 Prerrequisitos
- Docker instalado
- Nomad instalado

## 🚀 Instrucciones

1. **Iniciar Nomad en modo dev**:
   ```bash
   ./start-nomad.sh
   ```

2. **Desplegar aplicación web**:
   ```bash
   ./deploy-webapp.sh
   ```

3. **Verificar deployment**:
   ```bash
   ./check-deployment.sh
   ```

4. **Escalar aplicación**:
   ```bash
   ./scale-app.sh
   ```

5. **Limpiar recursos**:
   ```bash
   ./cleanup.sh
   ```

## ✅ Validación
El laboratorio se considera completado cuando:
- Nomad está ejecutándose correctamente
- La aplicación web se despliega exitosamente
- La aplicación es accesible vía HTTP
- El escalado funciona correctamente

## 🏆 Badge
Al completar este lab, obtienes el badge **Nomad Practitioner**.
