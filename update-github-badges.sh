#!/bin/bash

echo "🔄 Actualizando badges en GitHub..."

# Verificar si estamos en un Codespace
if [ -n "$CODESPACE_NAME" ]; then
    echo "📍 Ejecutándose en GitHub Codespace: $CODESPACE_NAME"
    
    # Crear archivo de estado de badges
    BADGE_STATUS_FILE="badge-status.json"
    
    echo "{" > $BADGE_STATUS_FILE
    echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," >> $BADGE_STATUS_FILE
    echo "  \"codespace\": \"$CODESPACE_NAME\"," >> $BADGE_STATUS_FILE
    echo "  \"badges\": {" >> $BADGE_STATUS_FILE
    
    # Verificar cada badge
    BADGES_FOUND=0
    
    for badge_file in $(find . -name ".badge-*-earned" 2>/dev/null | sort); do
        if [ $BADGES_FOUND -gt 0 ]; then
            echo "    ," >> $BADGE_STATUS_FILE
        fi
        
        badge_name=$(basename "$badge_file" | sed 's/.badge-\(.*\)-earned/\1/')
        badge_date=$(cat "$badge_file")
        
        echo "    \"$badge_name\": {" >> $BADGE_STATUS_FILE
        echo "      \"earned\": true," >> $BADGE_STATUS_FILE
        echo "      \"date\": \"$badge_date\"" >> $BADGE_STATUS_FILE
        echo -n "    }" >> $BADGE_STATUS_FILE
        
        ((BADGES_FOUND++))
    done
    
    echo "" >> $BADGE_STATUS_FILE
    echo "  }," >> $BADGE_STATUS_FILE
    echo "  \"foundational_badge\": $([ -f ".foundational-badge-earned" ] && echo "true" || echo "false")" >> $BADGE_STATUS_FILE
    echo "}" >> $BADGE_STATUS_FILE
    
    echo "✅ Estado de badges actualizado en $BADGE_STATUS_FILE"
    
    # Commit y push automático si hay cambios
    if [ -n "$GITHUB_TOKEN" ]; then
        git add $BADGE_STATUS_FILE
        if git diff --staged --quiet; then
            echo "📝 No hay cambios en badges para commitear"
        else
            git commit -m "🏆 Update badges: $BADGES_FOUND badges earned"
            git push
            echo "🚀 Badges actualizados en GitHub"
        fi
    else
        echo "⚠️  GITHUB_TOKEN no disponible - commit manual requerido"
    fi
    
else
    echo "⚠️  No se detectó GitHub Codespace - ejecutándose localmente"
fi
