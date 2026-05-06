FROM php:8.2-fpm-alpine AS base

# ── System deps ───────────────────────────────────────────────────────────────
RUN apk add --no-cache \
        caddy \
        postgresql-client \
        sqlite-libs \
        curl \
        unzip \
    && docker-php-ext-install pdo

# ── AgenDAV ───────────────────────────────────────────────────────────────────
ARG AGENDAV_VERSION=2.6.0
RUN curl -fsSL \
        "https://github.com/agendav/agendav/releases/download/${AGENDAV_VERSION}/agendav-${AGENDAV_VERSION}.tar.gz" \
        -o /tmp/agendav.tar.gz \
    && mkdir -p /var/www/agendav \
    && tar -xzf /tmp/agendav.tar.gz -C /var/www/agendav --strip-components=1 \
    && rm /tmp/agendav.tar.gz \
    && chown -R www-data:www-data /var/www/agendav

# ── PHP-FPM: listen on a Unix socket ─────────────────────────────────────────
RUN sed -i \
        -e 's|listen = 127.0.0.1:9000|listen = /run/php-fpm.sock|' \
        -e 's|;listen.owner = .*|listen.owner = caddy|' \
        -e 's|;listen.group = .*|listen.group = caddy|' \
        -e 's|;listen.mode = .*|listen.mode = 0660|' \
        /usr/local/etc/php-fpm.d/www.conf

# ── Caddy config ──────────────────────────────────────────────────────────────
COPY Caddyfile /etc/caddy/Caddyfile

# ── Entrypoint ────────────────────────────────────────────────────────────────
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
