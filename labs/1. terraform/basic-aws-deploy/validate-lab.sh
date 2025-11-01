#!/bin/bash

echo "🔍 Validando Laboratorio Terraform..."
echo "===================================="

VALIDATION_PASSED=true
SCORE=0
MAX_SCORE=5

# Test 1: Verificar que Terraform está inicializado
echo "📋 Test 1: Verificando inicialización de Terraform..."
if [ -d ".terraform" ] && [ -f ".terraform.lock.hcl" ]; then
    echo "✅ Terraform inicializado correctamente"
    ((SCORE++))
else
    echo "❌ Terraform no está inicializado. Ejecuta: terraform init"
    VALIDATION_PASSED=false
fi

# Test 2: Validar configuración de Terraform
echo "📋 Test 2: Validando configuración..."
if terraform validate > /dev/null 2>&1; then
    echo "✅ Configuración de Terraform válida"
    ((SCORE++))
else
    echo "❌ Configuración de Terraform inválida"
    terraform validate
    VALIDATION_PASSED=false
fi

# Test 3: Verificar que los recursos están aplicados
echo "📋 Test 3: Verificando recursos desplegados..."
if terraform show > /dev/null 2>&1; then
    BUCKET_NAME=$(terraform output -raw bucket_name 2>/dev/null)
    INSTANCE_ID=$(terraform output -raw instance_id 2>/dev/null)
    
    if [ ! -z "$BUCKET_NAME" ] && [ ! -z "$INSTANCE_ID" ]; then
        echo "✅ Recursos desplegados correctamente"
        echo "   📦 Bucket: $BUCKET_NAME"
        echo "   🖥️  Instancia: $INSTANCE_ID"
        ((SCORE++))
    else
        echo "❌ Recursos no encontrados. Ejecuta: terraform apply"
        VALIDATION_PASSED=false
    fi
else
    echo "❌ No hay estado de Terraform. Ejecuta: terraform apply"
    VALIDATION_PASSED=false
fi

# Test 4: Verificar recursos en AWS
echo "📋 Test 4: Verificando recursos en AWS..."
if [ ! -z "$BUCKET_NAME" ]; then
    if aws s3 ls "s3://$BUCKET_NAME" > /dev/null 2>&1; then
        echo "✅ Bucket S3 existe en AWS"
        ((SCORE++))
    else
        echo "❌ Bucket S3 no encontrado en AWS"
        VALIDATION_PASSED=false
    fi
fi

if [ ! -z "$INSTANCE_ID" ]; then
    INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null)
    if [ "$INSTANCE_STATE" = "running" ] || [ "$INSTANCE_STATE" = "pending" ]; then
        echo "✅ Instancia EC2 está ejecutándose (Estado: $INSTANCE_STATE)"
        ((SCORE++))
    else
        echo "❌ Instancia EC2 no está ejecutándose (Estado: $INSTANCE_STATE)"
        VALIDATION_PASSED=false
    fi
fi

# Mostrar resultado final
echo ""
echo "📊 RESULTADO DE LA VALIDACIÓN"
echo "=============================="
echo "Puntuación: $SCORE/$MAX_SCORE"

if [ "$VALIDATION_PASSED" = true ] && [ $SCORE -eq $MAX_SCORE ]; then
    echo "🎉 ¡LABORATORIO COMPLETADO EXITOSAMENTE!"
    echo "🏆 Badge obtenido: Terraform Practitioner"
    echo ""
    echo "Has demostrado que puedes:"
    echo "✅ Configurar y usar Terraform"
    echo "✅ Crear recursos en AWS"
    echo "✅ Gestionar estado de infraestructura"
    echo "✅ Usar variables y outputs"
    echo ""
    echo "🎯 Próximo paso: Continúa con el laboratorio de Vault"
    
    # Crear archivo de badge con timestamp
    echo "$(date +%Y%m%d-%H%M%S)" > .badge-terraform-earned
    echo "🏆 Badge Terraform Practitioner generado automáticamente!"
    
    # Sincronizar con GitHub si estamos en Codespace
    if [ -n "$CODESPACE_NAME" ]; then
        echo "🔄 Sincronizando badge con GitHub..."
        cd ../../.. && ./update-github-badges.sh
    fi
    
    exit 0
else
    echo "❌ LABORATORIO INCOMPLETO"
    echo "Por favor, completa todos los pasos antes de continuar."
    echo ""
    echo "💡 Consejos:"
    echo "- Verifica tus credenciales AWS: aws sts get-caller-identity"
    echo "- Asegúrate de haber ejecutado: terraform apply"
    echo "- Revisa los outputs: terraform output"
    exit 1
fi
