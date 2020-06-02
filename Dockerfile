FROM python:slim

ARG UPSTREAM_VERSION
ARG MAXMIND_LICENSE_KEY

ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

RUN apt-get update \
  && apt-get install -y git software-properties-common wget \
  && add-apt-repository ppa:longsleep/golang-backports \
  && apt-get install -y golang-go

RUN go get -v -u github.com/kelseyhightower/confd \
  && rm -rf /go/src/github.com/kelseyhightower/confd \
  && pip install gunicorn \
  && mkdir /openvpn-monitor \
  && wget -O - https://github.com/furlongm/openvpn-monitor/archive/${UPSTREAM_VERSION}.tar.gz | tar -C /openvpn-monitor --strip-components=1 -zxvf - \
  && cp /openvpn-monitor/openvpn-monitor.conf.example /openvpn-monitor/openvpn-monitor.conf \
  && pip install /openvpn-monitor \
  && mkdir -p /var/lib/GeoIP/ \
  && wget -O - "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMIND_LICENSE_KEY&suffix=tar.gz" | tar -C /var/lib/GeoIP/ --strip-components=1 -zxvf - \
  && rm -rf /var/lib/apt/lists/ \
  && rm -rf $GOROOT \
  && rm -rf $GOPATH/src

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /openvpn-monitor

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
