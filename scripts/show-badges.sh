#!/bin/bash

echo "🏆 HashiCorp Terraform Labs - Estado de Badges"
echo "==============================================="

# Contar badges obtenidos
EARNED_BADGES=$(find . -name ".badge-*-earned" 2>/dev/null | wc -l)
TOTAL_BADGES=1

echo ""
echo "📊 Progreso: $EARNED_BADGES/$TOTAL_BADGES badges obtenidos"
echo ""

# Mostrar badges obtenidos
if [ $EARNED_BADGES -gt 0 ]; then
    echo "✅ Badges Obtenidos:"
    for badge_file in $(find . -name ".badge-*-earned" 2>/dev/null | sort); do
        badge_name=$(basename "$badge_file" | sed 's/.badge-\(.*\)-earned/\1/' | tr '[:lower:]' '[:upper:]')
        badge_date=$(cat "$badge_file")
        echo "🏆 $badge_name Practitioner (obtenido: $badge_date)"
    done
    echo ""
fi

# Mostrar badges pendientes
echo "⏳ Badges Pendientes:"
declare -A all_badges=(
    ["terraform"]="Terraform Practitioner"
    # ["vault"]="Vault Practitioner" 
    # ["nomad"]="Nomad Practitioner"
    # ["consul"]="Consul Practitioner"
    # ["vault-radar"]="Vault Radar Practitioner"
)

for badge in "${!all_badges[@]}"; do
    if [ ! -f ".badge-${badge// /-}-earned" ]; then
        echo "⭕ ${all_badges[$badge]}"
    fi
done

echo ""

# Verificar badge fundacional
if [ -f ".foundational-badge-earned" ]; then
    foundational_date=$(cat ".foundational-badge-earned")
    echo "🎖️  BADGE FUNDACIONAL OBTENIDO:"
    echo "🏆 HashiCorp Foundational Complete (obtenido: $foundational_date)"
else
    echo "🎯 Badge Fundacional: Completa todos los labs para desbloquearlo"
fi

echo ""
echo "💡 Ejecuta './scripts/validate-all-labs.sh' para validar y obtener badges"
