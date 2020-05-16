FROM python:3-alpine

ARG MAXMIND_LICENSE_KEY

ENV VERSION=ed346321ec2dbd3298ca52e5f6cd30407f3e343a

RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers musl-dev openssl tar \
  && wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 \
  && chmod a+x /usr/bin/confd \
  && pip install gunicorn \
  && mkdir /openvpn-monitor \
  && wget -O - https://github.com/furlongm/openvpn-monitor/archive/${VERSION}.tar.gz | tar -C /openvpn-monitor --strip-components=1 -zxvf - \
  && cp /openvpn-monitor/openvpn-monitor.conf.example /openvpn-monitor/openvpn-monitor.conf \
  && pip install /openvpn-monitor \
  && apk del --no-cache .build-dependencies \
  && mkdir -p /var/lib/GeoIP/ \
  && wget -O - "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMIND_LICENSE_KEY&suffix=tar.gz" | tar -C /var/lib/GeoIP/ --strip-components=1 -zxvf -

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /openvpn-monitor

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
