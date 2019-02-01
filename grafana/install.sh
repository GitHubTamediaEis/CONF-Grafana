#!/bin/bash
# Installation script of Grafana from rpm
# x.y.z = release

# Define release of grafana and deduce installation directory
RELEASE=${GRAFANA_RELEASE:-5.4.2-1}
DIR=grafana-$RELEASE.linux-amd64
# Install if not already installed
if \! rpm -q grafana;  then
    RPMFILE=grafana-${RELEASE}.x86_64.rpm
    URL="https://dl.grafana.com/oss/release/$RPMFILE"
    yum install -y $URL
    if [ $? != 0 ]; then
	echo "Installation of $URL failed"
	exit 1
    fi
    # cp prometheus datasource
    . /etc/Tamedia
    sed s/\$PROMETHEUSADDRESS/$PROMETHEUSADDRESS/g datasource_prometheus.yaml > /etc/grafana/provisioning/datasources/prometheus.yaml
    # Set start-stop script
    chkconfig --add grafana-server
    service grafana-server start
else
    echo "Grafana already installed: Nothing done"
fi


