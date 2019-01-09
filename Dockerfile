FROM python:3-alpine

RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers geoip-dev musl-dev openssl tar \
  && wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 \
  && chmod a+x /usr/bin/confd \
  && pip install gunicorn

ENV VERSION=1.0.0

RUN mkdir /openvpn-monitor \
  && wget -O - https://github.com/furlongm/openvpn-monitor/archive/${VERSION}.tar.gz | tar -C /openvpn-monitor --strip-components=1 -zxvf -
COPY openvpn-monitor.conf /openvpn-monitor
RUN pip install /openvpn-monitor

RUN apk del .build-dependencies

RUN mkdir -p /usr/share/GeoIP/ \
  && cd /usr/share/GeoIP/ \
  && wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz \
  && tar zxvf GeoLite2-City.tar.gz GeoLite2-City_20190101/GeoLite2-City.mmdb
  # this tiny tar doesn't allow wildcards. therefore db build date is hardcoded...
  # also it does not have --no-anchored flag :/

RUN apk add --no-cache geoip

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /openvpn-monitor

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
