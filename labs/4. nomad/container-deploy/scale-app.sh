#!/bin/bash

export NOMAD_ADDR=http://localhost:4646

echo "📈 Escalando aplicación web..."

# Crear versión escalada del job
cat > webapp-scaled.nomad << EOF
job "webapp" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    count = 3  # Escalar a 3 instancias

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "webapp"
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:alpine"
        ports = ["http"]
        
        volumes = [
          "local:/usr/share/nginx/html"
        ]
      }

      template {
        data = <<EOH
<!DOCTYPE html>
<html>
<head>
    <title>HashiCorp Nomad Lab - Scaled</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f4; }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo { color: #00CA8E; font-size: 24px; font-weight: bold; }
        .status { color: #28a745; }
        .scaled { background: #e7f3ff; padding: 10px; border-left: 4px solid #00CA8E; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🚀 HashiCorp Nomad Lab</div>
        <h2>¡Aplicación escalada exitosamente!</h2>
        <div class="scaled">
            <strong>📈 ESCALADO ACTIVO</strong><br>
            Esta instancia es parte de un deployment escalado
        </div>
        <p class="status">✅ Estado: Ejecutándose</p>
        <p>📅 Desplegado: {{ timestamp }}</p>
        <p>🏷️ Job: webapp (escalado)</p>
        <p>🔧 Driver: Docker</p>
        <p>📊 Instancias: 3</p>
        
        <h3>Información del Nodo:</h3>
        <ul>
            <li>Datacenter: {{ env "NOMAD_DC" }}</li>
            <li>Región: {{ env "NOMAD_REGION" }}</li>
            <li>Job ID: {{ env "NOMAD_JOB_ID" }}</li>
            <li>Alloc ID: {{ env "NOMAD_ALLOC_ID" }}</li>
        </ul>
    </div>
</body>
</html>
EOH
        destination = "local/index.html"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
EOF

# Aplicar la configuración escalada
echo "🚀 Aplicando escalado..."
nomad job run webapp-scaled.nomad

# Esperar a que el escalado se complete
echo "⏳ Esperando a que el escalado se complete..."
sleep 15

# Verificar el estado del escalado
echo "📊 Estado del escalado:"
nomad job status webapp

echo ""
echo "🔍 Allocations activas:"
nomad job allocs webapp

echo ""
echo "✅ Escalado completado - La aplicación ahora tiene 3 instancias"
