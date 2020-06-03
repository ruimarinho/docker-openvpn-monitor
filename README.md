# ruimarinho/openvpn-monitor

[![build status][github-image]][github-url]
[![ruimarinho/openvpn-monitor][docker-stars-image]][docker-hub-url]  [![ruimarinho/openvpn-monitor][docker-pulls-image]][docker-hub-url]

The trusted multi-platform [web-based OpenVPN Monitor](http://openvpn-monitor.openbytes.ie) docker image.

* `amd64` (`x86_64`)
* `arm64` (`aarch64`, `armv8`)
* `arm32v7` (`armv7`)
* `arm32v6` (`armv6`)
* `i386`

## What is OpenVPN Monitor?

OpenVPN Monitor is a web-based utility that displays the status of OpenVPN servers. It includes information such as the usernames/hostnames connected, remote and VPN IP addresses, approximate locations (using GeoIP), traffic consumption and more.

## Usage

First, make sure OpenVPN is configured to open the management interface that the OpenVPN Monitor connects to. Edit the `openvpn.conf` file and add the following directive (choose port `5555` or any other of your preference):

```
management 127.0.0.1 5555
```

Note: if you're running OpenVPN in a container as well, allow for external connections with:

```
management 0.0.0.0 5555
```

All settings of OpenVPN Monitor can be dynamically configured via environment variables (thanks to confd) without having to create a new image or bind-mounting the configuration file.

The environment variable are organized into two groups:

- `OPENVPNMONITOR_DEFAULT_<PROPERTY>`: populates the global `[OpenVPN-Monitor]` section.
- `OPENVPNMONITOR_SITES_<INDEX>_<PROPERTY>`: populates each site section. **Note: if property contains underscores, like `datetime_format` and `show_disconnect`, you must pass those properties without the underscore. See example below.**

By default, GeoIP is automatically available (no additional download step is required). For this reason, the location of the `geoip_data` file is hardcoded in the configuration file. The `datetime_format` defaults to `%d/%m/%Y %H:%M:%S` if none is provided. Everything else must be set and there is no whitelist of property names. This ensures compatibility of this image with future versions of OpenVPN monitor without too much maintenance.

So a minimal and accessible, yet non-functional, version of OpenVPN Monitor can be reduced to:

```
docker run -p 80:80 --rm ruimarinho/openvpn-monitor
```

Let's add some configuration, including changing the page name, adding a logo, some geolocation features and two sites - one that connects to a running TCP OpenVPN server and another one to an UDP server.

Using the scheme above, the configuration is as simple as setting the appropriate environment variables:

```
docker run --name openvpn-monitor \
  -e OPENVPNMONITOR_DEFAULT_DATETIMEFORMAT="%%d/%%m/%%Y" \
  -e OPENVPNMONITOR_DEFAULT_LATITUDE=-37 \
  -e OPENVPNMONITOR_DEFAULT_LOGO=logo.jpg \
  -e OPENVPNMONITOR_DEFAULT_LONGITUDE=144 \
  -e OPENVPNMONITOR_DEFAULT_MAPS=True \
  -e OPENVPNMONITOR_DEFAULT_SITE=Test \
  -e OPENVPNMONITOR_SITES_0_ALIAS=UDP \
  -e OPENVPNMONITOR_SITES_0_HOST=openvpn-udp \
  -e OPENVPNMONITOR_SITES_0_NAME=UDP \
  -e OPENVPNMONITOR_SITES_0_PORT=5555 \
  -e OPENVPNMONITOR_SITES_0_SHOWDISCONNECT=True \
  -e OPENVPNMONITOR_SITES_1_ALIAS=TCP \
  -e OPENVPNMONITOR_SITES_1_HOST=openvpn-udp \
  -e OPENVPNMONITOR_SITES_1_NAME=TCP \
  -e OPENVPNMONITOR_SITES_1_PORT=5555 \
  -p 80:80 ruimarinho/openvpn-monitor
```

Now OpenVPN Monitor should be accessible via http://127.0.0.1:80.

*Note that for the `logo.jpg` to be readable, you need to bind-mount it or pass an URL instead. Also, the datetime format needs to be escaped as shown above (suing two %).*

## Supported Docker versions

This image is officially supported on Docker version 1.12, with support for older versions provided on a best-effort basis.

## License

MIT

[docker-hub-url]: https://hub.docker.com/r/ruimarinho/openvpn-monitor
[docker-pulls-image]: https://img.shields.io/docker/pulls/ruimarinho/openvpn-monitor.svg?style=flat-square
[docker-stars-image]: https://img.shields.io/docker/stars/ruimarinho/openvpn-monitor.svg?style=flat-square
[github-image]: https://github.com/ruimarinho/docker-openvpn-monitor/workflows/build/badge.svg
[github-url]: https://github.com/ruimarinho/docker-openvpn-monitor/actions
