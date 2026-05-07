# ── Stage 1: grab the official Caddy binary ───────────────────────────────────
# The official caddy image ships a complete build that includes the
# 'static' trusted_proxies module. The Alpine package repo does not.
FROM caddy:2-alpine AS caddy
 
# ── Stage 2: PHP-FPM + AgenDAV ───────────────────────────────────────────────
FROM php:8.2-fpm-alpine


ENV AGENDAV_TIMEZONE=UTC
ENV PHP_INI_DIR /usr/local/etc/php
 
# ── Copy Caddy from the official image ────────────────────────────────────────
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

# ── System deps ───────────────────────────────────────────────────────────────
RUN apk add --no-cache \
        postgresql-client \
        sqlite-libs \
        curl \
        unzip \
        apt-transport-https \
        ca-certificates \
    && docker-php-ext-install pdo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ── AgenDAV ───────────────────────────────────────────────────────────────────
ARG AGENDAV_VERSION=2.6.0
RUN curl -fsSL \
        "https://github.com/agendav/agendav/releases/download/${AGENDAV_VERSION}/agendav-${AGENDAV_VERSION}.tar.gz" \
        -o /tmp/agendav.tar.gz \
    && mkdir -p /var/www/agendav \
    && tar -xzf /tmp/agendav.tar.gz -C /var/www/agendav --strip-components=1 \
    && rm /tmp/agendav.tar.gz \
    && chown -R www-data:www-data /var/www/agendav

# ── PHP-FPM: Unix socket config ───────────────────────────────────────────────
# Drop a dedicated pool override instead of sed-patching the default www.conf,
# which is fragile due to varying comment styles across image versions.
COPY php-fpm-pool.conf /usr/local/etc/php-fpm.d/zz-socket.conf

# ── Caddy config ──────────────────────────────────────────────────────────────
COPY Caddyfile /etc/caddy/Caddyfile

# ── Entrypoint ────────────────────────────────────────────────────────────────
COPY entrypoint.sh /entrypoint.sh
RUN mkdir -p /var/agendav && \
    touch /var/agendav/db.sqlite && \
    chown -R www-data:www-data /var/agendav && \
    chmod 640 /var/agendav/db.sqlite && \
    chmod 644 /etc/ssl/certs/cacert.pem && \
    chown -R www-data:www-data ${PHP_INI_DIR} && \
    cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini && \
    echo 'date.timezone = "AGENDAV_TIMEZONE"' >> ${PHP_INI_DIR}/php.ini && \
    echo 'magic_quotes_runtime = false' >> ${PHP_INI_DIR}/php.ini && \
    echo 'openssl.cafile = "/etc/ssl/certs/cacert.pem"' >> ${PHP_INI_DIR}/php.ini && \
    echo 'curl.cainfo = "/etc/ssl/certs/cacert.pem"' >> ${PHP_INI_DIR}/php.ini && \
    chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
