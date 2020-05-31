FROM python:3-alpine

ARG UPSTREAM_VERSION

RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers musl-dev openssl tar \
  && wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 \
  && chmod a+x /usr/bin/confd \
  && pip install gunicorn \
  && mkdir /openvpn-monitor \
  && wget -O - https://github.com/furlongm/openvpn-monitor/archive/${UPSTREAM_VERSION}.tar.gz | tar -C /openvpn-monitor --strip-components=1 -zxvf - \
  && cp /openvpn-monitor/openvpn-monitor.conf.example /openvpn-monitor/openvpn-monitor.conf \
  && pip install /openvpn-monitor \
  && apk del --no-cache .build-dependencies \
  && mkdir -p /var/lib/GeoIP/ \
  && wget -O - "https://web.archive.org/web/20191227182209/https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz" | tar -C /var/lib/GeoIP/ --strip-components=1 -zxvf -

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /openvpn-monitor

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
