# ttyd for IPFire

This project adds a ttyd browser terminal entry to the IPFire WebUI.

It installs:

- `/srv/web/ipfire/cgi-bin/ttyd.cgi`
- `/var/ipfire/menu.d/EX-ttyd.menu`
- `/etc/rc.d/init.d/ttyd`
- `/etc/sysconfig/ttyd`
- `/opt/ttyd/bin/ttyd`

The installer also updates the IPFire WebUI Content Security Policy to allow
the embedded ttyd iframe on port `7681`, and restores the original CSP on
uninstall.

The terminal runs SSH as `root` to `127.0.0.1:22`.
Authentication and shell permissions remain controlled by IPFire SSH.

## Certificate model

The service uses the existing IPFire WebUI certificate. It first reads the
active Apache WebUI configuration:

- `/etc/httpd/conf/vhosts.d/ipfire-interface-ssl.conf`

Then it falls back to:

- `/etc/httpd/server-ecdsa.crt`
- `/etc/httpd/server-ecdsa.key`
- `/etc/httpd/server.crt`
- `/etc/httpd/server.key`

It does not generate its own certificate.

## ttyd runtime

The bundled ttyd runtime is stored directly in the install tree:

```text
src/opt/ttyd/bin/ttyd
```

The service also accepts ttyd from these fallback locations:

```text
/opt/ttyd/bin/ttyd
/usr/bin/ttyd
/usr/local/bin/ttyd
```

## Install

```sh
cd "ttyd for IPFire"
chmod +x install.sh uninstall.sh src/etc/rc.d/init.d/ttyd src/srv/web/ipfire/cgi-bin/ttyd.cgi src/opt/ttyd/bin/ttyd
./install.sh
```

Run the installer as `root` from the project directory after copying it to IPFire.

To remove:

```sh
cd "ttyd for IPFire"
./uninstall.sh
```
