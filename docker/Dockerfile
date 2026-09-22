# ============================================================
# Dockerfile - Servicio de aplicación (PHP 8.2 + Laravel)
# Proyecto Clínica Digital
#
# Nota: este proyecto NO usa arquitectura de microservicios,
# por lo que se define un único servicio de aplicación en vez
# de un Dockerfile por "auth", "catálogo", "pedidos", "pagos"
# como sugiere el ejemplo genérico de la guía.
# ============================================================

FROM php:8.2-fpm

# Dependencias del sistema necesarias para las extensiones de PHP
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    default-mysql-client \
  && rm -rf /var/lib/apt/lists/*

# Extensiones de PHP requeridas por Laravel y por la conexión a MySQL
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Composer (gestor de dependencias de PHP)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copiar el código fuente de la aplicación
COPY ./src /var/www/html

# Instalar dependencias de producción (se omite si aún no hay composer.json)
RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader; fi

# Permisos para las carpetas que Laravel necesita escribir
RUN mkdir -p storage bootstrap/cache \
  && chown -R www-data:www-data storage bootstrap/cache || true

EXPOSE 9000

CMD ["php-fpm"]
