# Lab Vault Radar: Escaneo de Repositorios

![Vault Radar](https://img.shields.io/badge/Vault%20Radar-Practitioner-FFD814?style=flat&logo=vault)

## 🎯 Objetivo
Usar Vault Radar para escanear repositorios en busca de secretos expuestos.

## ⏱️ Duración
10-15 minutos

## 📋 Prerrequisitos
- Vault Radar CLI instalado
- Git instalado

## 🚀 Instrucciones

1. **Crear repositorio de prueba con secretos**:
   ```bash
   ./create-test-repo.sh
   ```

2. **Escanear repositorio local**:
   ```bash
   ./scan-local-repo.sh
   ```

3. **Revisar resultados**:
   ```bash
   ./review-results.sh
   ```

4. **Limpiar secretos encontrados**:
   ```bash
   ./fix-secrets.sh
   ```

5. **Verificar limpieza**:
   ```bash
   ./verify-clean.sh
   ```

## ✅ Validación
El laboratorio se considera completado cuando:
- Vault Radar detecta secretos en el repositorio
- Se genera un reporte de escaneo
- Los secretos son identificados correctamente
- Se verifica la limpieza del repositorio

## 🏆 Badge
Al completar este lab, obtienes el badge **Vault Radar Practitioner**.
