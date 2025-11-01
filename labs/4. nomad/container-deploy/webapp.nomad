job "webapp" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    count = 1

    network {
      port "http" {
        static = 8080
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
        data = <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>HashiCorp Nomad Lab</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f4f4; }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .logo { color: #00CA8E; font-size: 24px; font-weight: bold; }
        .status { color: #28a745; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🚀 HashiCorp Nomad Lab</div>
        <h2>¡Aplicación desplegada exitosamente!</h2>
        <p class="status">✅ Estado: Ejecutándose</p>
        <p>📅 Desplegado: {{ timestamp }}</p>
        <p>🏷️ Job: webapp</p>
        <p>🔧 Driver: Docker</p>
        <p>🌐 Puerto: 8080</p>
        
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
EOF
        destination = "local/index.html"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
