#!/bin/sh
set -e

confd -onetime -backend env --log-level debug

cat openvpn-monitor.conf

exec "$@"
