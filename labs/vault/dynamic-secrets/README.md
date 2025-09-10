# Lab Vault: Secretos Dinámicos

![Vault](https://img.shields.io/badge/Vault-Practitioner-FFD814?style=flat&logo=vault)

## 🎯 Objetivo
Configurar Vault para generar credenciales dinámicas de base de datos.

## ⏱️ Duración
10-15 minutos

## 📋 Prerrequisitos
- Docker instalado
- Vault CLI instalado

## 🚀 Instrucciones

1. **Iniciar Vault en modo dev**:
   ```bash
   ./start-vault.sh
   ```

2. **Configurar el motor de base de datos**:
   ```bash
   ./configure-db-engine.sh
   ```

3. **Generar credenciales dinámicas**:
   ```bash
   ./generate-credentials.sh
   ```

4. **Verificar credenciales**:
   ```bash
   ./verify-credentials.sh
   ```

5. **Limpiar entorno**:
   ```bash
   ./cleanup.sh
   ```

## ✅ Validación
El laboratorio se considera completado cuando:
- Vault está ejecutándose correctamente
- El motor de base de datos está habilitado
- Se generan credenciales dinámicas válidas
- Las credenciales funcionan para conectar a la DB

## 🏆 Badge
Al completar este lab, obtienes el badge **Vault Practitioner**.
