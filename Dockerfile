# ── Stage 1: grab the official Caddy binary ───────────────────────────────────
# The official caddy image ships a complete build that includes the
# 'static' trusted_proxies module. The Alpine package repo does not.
FROM caddy:2-alpine AS caddy
 
# ── Stage 2: PHP-FPM + AgenDAV ───────────────────────────────────────────────
FROM php:8.2-fpm-alpine

# ── Copy Caddy from the official image ────────────────────────────────────────
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

# ── System deps ───────────────────────────────────────────────────────────────
RUN apk add --no-cache \
        postgresql-client \
        sqlite-libs \
        git \
        unzip \
        ca-certificates \
    && docker-php-ext-install pdo
ADD https://curl.se/ca/cacert.pem /etc/ssl/certs/

# ── AgenDAV ───────────────────────────────────────────────────────────────────
ARG AGENDAV_VERSION=2.6.0
#RUN curl -fsSL \
#        "https://github.com/agendav/agendav/releases/download/${AGENDAV_VERSION}/agendav-${AGENDAV_VERSION}.tar.gz" \
#        -o /tmp/agendav.tar.gz \
#    && mkdir -p /var/www/agendav \
#    && tar -xzf /tmp/agendav.tar.gz -C /var/www/agendav --strip-components=1 \
#    && rm /tmp/agendav.tar.gz \
#    && chown -R www-data:www-data /var/www/agendav
RUN git clone https://github.com/dmwg/agendav/ /var/www/agendav
COPY vendor /var/www/agendav/web/vendor
RUN chown -R www-data:www-data /var/www/agendav

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
    chmod 640 /var/agendav/db.sqlite && \
    chown -R www-data:www-data /var/agendav && \
    chmod 644 /etc/ssl/certs/cacert.pem && \
    chown -R www-data:www-data /usr/local/etc/php && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    echo 'date.timezone = "Europe/Berlin"' >> /usr/local/etc/php/php.ini && \
    echo 'magic_quotes_runtime = false' >> /usr/local/etc/php/php.ini && \
    echo 'openssl.cafile = "/etc/ssl/certs/cacert.pem"' >> /usr/local/etc/php/php.ini && \
    echo 'curl.cainfo = "/etc/ssl/certs/cacert.pem"' >> /usr/local/etc/php/php.ini && \
    chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
