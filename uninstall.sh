#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
	echo "Please run this uninstaller as root."
	exit 1
fi

/etc/rc.d/init.d/ttyd stop >/dev/null 2>&1 || true

for conf in /etc/httpd/conf/vhosts.d/ipfire-interface.conf /etc/httpd/conf/vhosts.d/ipfire-interface-ssl.conf; do
	if [ -f "${conf}.ttyd.bak" ]; then
		mv -f "${conf}.ttyd.bak" "$conf"
	elif [ -f "$conf" ]; then
		sed -i "s#; frame-src 'self' https://\\*:7681##g" "$conf"
	fi
done
apachectl -k graceful >/dev/null 2>&1 || /etc/rc.d/init.d/apache restart >/dev/null 2>&1 || true

rm -f \
	/etc/rc.d/init.d/ttyd \
	/etc/rc.d/rc3.d/S99ttyd \
	/etc/rc.d/rc0.d/K01ttyd \
	/etc/rc.d/rc6.d/K01ttyd \
	/etc/sysconfig/ttyd \
	/srv/web/ipfire/cgi-bin/ttyd.cgi \
	/var/ipfire/menu.d/EX-ttyd.menu \
	/var/log/ttyd.log \
	/run/ttyd.pid

rm -rf /opt/ttyd
rm -f /opt/pakfire/db/rootfiles/ttyd

echo "ttyd for IPFire has been uninstalled."
