#!/bin/sh
set -e

if ! [ -e /openvpn-monitor/openvpn-monitor.conf ]; then
  confd -onetime -backend env --log-level panic 
fi

exec "$@"
