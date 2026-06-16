#!/bin/sh
set -eu

NAME="${NAME:-ttyd}"

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

log() {
	printf '%b%s%b\n' "$1" "$2" "$RESET"
}

patch_webui_csp() {
	for conf in /etc/httpd/conf/vhosts.d/ipfire-interface.conf /etc/httpd/conf/vhosts.d/ipfire-interface-ssl.conf; do
		[ -f "$conf" ] || continue
		grep -q "Content-Security-Policy" "$conf" || continue
		grep -q "frame-src 'self' https://\\*:7681" "$conf" && continue

		cp -p "$conf" "${conf}.ttyd.bak" 2>/dev/null || true
		sed -i "s#img-src 'self' data:#img-src 'self' data:; frame-src 'self' https://*:7681#g" "$conf"
	done

	apachectl -k graceful >/dev/null 2>&1 || /etc/rc.d/init.d/apache restart >/dev/null 2>&1 || true
}

if [ "$(id -u)" -ne 0 ]; then
	echo "Please run this installer as root."
	exit 1
fi

log "$GREEN" "====== ttyd for IPFire installer ======"

log "$YELLOW" "Stopping old service..."
/etc/rc.d/init.d/ttyd stop >/dev/null 2>&1 || true

if [ ! -d src ]; then
	echo "Missing src directory. Run this installer from the ttyd for IPFire project directory."
	exit 1
fi

log "$YELLOW" "Copying project files..."
cp -R -f src/. /

log "$YELLOW" "Setting permissions..."
chown root:root /etc/rc.d/init.d/ttyd /etc/sysconfig/ttyd /srv/web/ipfire/cgi-bin/ttyd.cgi 2>/dev/null || true
chown -R root:root /opt/ttyd 2>/dev/null || true
chmod 0755 /etc/rc.d/init.d/ttyd 2>/dev/null || true
chmod 0755 /srv/web/ipfire/cgi-bin/ttyd.cgi 2>/dev/null || true
chmod 0644 /etc/sysconfig/ttyd 2>/dev/null || true
chmod 0644 /var/ipfire/menu.d/EX-ttyd.menu 2>/dev/null || true
chown nobody:nobody /var/ipfire/menu.d/EX-ttyd.menu 2>/dev/null || true
chmod 0755 /opt/ttyd/bin/ttyd 2>/dev/null || true

log "$YELLOW" "Registering service autostart..."
ln -sf ../init.d/ttyd /etc/rc.d/rc3.d/S99ttyd
ln -sf ../init.d/ttyd /etc/rc.d/rc0.d/K01ttyd
ln -sf ../init.d/ttyd /etc/rc.d/rc6.d/K01ttyd

log "$YELLOW" "Allowing ttyd iframe in IPFire WebUI CSP..."
patch_webui_csp

if ! command -v /opt/ttyd/bin/ttyd >/dev/null 2>&1 && \
   ! command -v /usr/bin/ttyd >/dev/null 2>&1 && \
   ! command -v /usr/local/bin/ttyd >/dev/null 2>&1; then
	log "$YELLOW" "ttyd binary is not bundled. Place ttyd at /opt/ttyd/bin/ttyd or install it separately before starting the service."
fi

log "$YELLOW" "Starting service..."
if /etc/rc.d/init.d/ttyd start; then
	log "$GREEN" "Installation complete. Refresh the IPFire WebUI and open IPFire > ttyd."
else
	log "$RED" "Installation finished, but ttyd did not start. Check /var/log/ttyd.log and confirm SSH plus WebUI certificates are available."
fi
