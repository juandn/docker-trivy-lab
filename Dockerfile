# =============================================
# DOCKERFILE VULNERABLE - LABORATORIO TRIVY
# =============================================
#
# OBJETIVO: Identificar y corregir los problemas de seguridad
# que detecta Trivy para que el escaneo pase sin errores.
#
# LISTADO DE ACCIONES A REALIZAR:
#
# [x] 1. Cambiar la imagen base debian:10 (EOL) por debian:13-slim
#        → Elimina la mayoría de CVEs HIGH/CRITICAL
#
# [x] 2. Unificar los RUN de apt-get en un solo comando encadenado
#        → apt-get update && apt-get install -y ... && rm -rf /var/lib/apt/lists/*
#        → Menos capas, sin caché residual, imagen más ligera
#        → No aplicamos el rm, las imagenes de debian y ubuntu deberian encargarse ellas de hacer un apt clean segun doc https://docs.docker.com/build/building/best-practices/#apt-get
#
# [x] 3. Eliminar el secreto hardcodeado (SECRET_KEY=...)
#        → Los secretos nunca van en la imagen; usar variables de entorno en runtime
#
# [x] 4. Activar el usuario no-root ya creado (appuser)
#        → Añadir USER appuser antes del CMD
#
# [x] 5. Reemplazar el CMD con la backdoor de netcat
#        → Sustituir por un servidor legítimo, p.ej. python3 -m http.server
#
#
# =============================================

# === IMAGEN BASE ===
# TODO: Cambiar esta imagen base (debian:13-slim es más moderna y segura)
FROM debian:13-slim

# === INSTALACIÓN DE PAQUETES ===
# Cada RUN es una capa nueva → imagen más grande, cache ineficiente
RUN apt-get update && apt-get install -y openssl && apt-get install -y netcat-traditional
# Sin rm -rf /var/lib/apt/lists/* → la caché de apt se queda en la imagen
# Pero según doc de docker: Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.

# === USUARIO ===
# TODO: Crear usuario no-root y cambiar a él
RUN useradd -m -u 1001 appuser

# === SECRETOS (MALÍSIMA PRÁCTICA) ===
# TODO: Eliminar completamente esta línea


COPY index.html /var/www/html/index.html

# === INFORMACIÓN DEL SISTEMA ===
# TODO: Eliminar esta línea (no debe quedar rastro del host)

EXPOSE 80

# Activar usuario no root
USER appuser

# === COMANDO DE INICIO ===
# TODO: Reemplazar por un comando seguro
CMD ["sh", "-c", "while true; do python3 -m http.server; done"]

# =============================================
# RESUMEN DE CAMBIOS RECOMENDADOS:
# - Imagen base moderna y mínima
# - Usuario no-root
# - Sin secretos en la imagen
# - Menos capas (mejor cache y seguridad)
# - CMD seguro
# =============================================
