# ttyd for IPFire

[![IPFire](https://img.shields.io/badge/IPFire-2.29%20Core%20203-red)](https://www.ipfire.org/)
[![ttyd](https://img.shields.io/badge/ttyd-Web%20Terminal-blue)](https://github.com/tsl0922/ttyd)

This unofficial plugin integrates the excellent ttyd web terminal into the IPFire WebUI, allowing administrators to access a terminal session directly from their browser without needing a separate SSH client.

## Features

* Adds a ttyd entry to the IPFire WebUI
* Browser-based terminal access
* Simple installation and removal scripts

Tested on IPFire 2.29 (x86_64) Core Update 203

![](image/ttyd.png)

## Installation

```sh
sh install.sh
```
Run the installer as root from the project directory after copying it to your IPFire system.

## Uninstallation

```sh
sh uninstall.sh
```
## Disclaimer
This is an unofficial community project and is not affiliated with or supported by the IPFire team. Please review the code and use it at your own discretion.
