#!/bin/sh
set -e

# ── Sanity checks ─────────────────────────────────────────────────────────────
if [ ! -f /var/www/agendav/web/config/settings.php ]; then
    echo "ERROR: /var/www/agendav/web/config/settings.php not found."
    echo "       Mount your settings.php at that path before starting the container."
    exit 1
fi

# ── Run DB migrations (idempotent) ────────────────────────────────────────────
#~ echo "Running AgenDAV database migrations..."
cd /var/www/agendav
yes | php agendavcli migrations:migrate

# ── Start PHP-FPM in the background ──────────────────────────────────────────
echo "Starting PHP-FPM..."
php-fpm --daemonize

# ── Hand off to Caddy (PID 1) ────────────────────────────────────────────────
echo "Starting Caddy..."
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
