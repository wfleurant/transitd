#!/bin/sh

uci del firewall.transitdofflinehttp
uci commit firewall

/etc/init.d/firewall reload

uci del dhcp.@dnsmasq[-1].address
uci commit dhcp

/etc/init.d/dnsmasq reload
