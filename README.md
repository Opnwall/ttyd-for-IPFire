# ttyd for IPFire

This project adds a ttyd browser terminal entry to the IPFire WebUI.

The installer also updates the IPFire WebUI Content Security Policy to allow
the embedded ttyd iframe on port `7681`, and restores the original CSP on
uninstall.

The terminal runs SSH as `root` to `127.0.0.1:22`.
Authentication and shell permissions remain controlled by IPFire SSH.

Tested and verified in the following environments:

- IPFire 2.29 (x86_64) - 203 Development 

![](image/ttyd.png)

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

## Install

```sh
sh install.sh
```

Run the installer as `root` from the project directory after copying it to IPFire.

To remove:

```sh
sh uninstall.sh
```
## Disclaimer
This is an unofficial plugin and is not supported by the IPFire team; use at your own risk.
