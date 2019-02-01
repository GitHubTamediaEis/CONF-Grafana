#!/bin/bash
# Installation script of Grafana.
# Will by installed in /opt/grafana-x.y.z.linux-amd64
# with x.y.z = release

# Define release of grafana and deduce installation directory
RELEASE=${GRAFANA_RELEASE:-5.4.2-1}
DIR=grafana-$RELEASE.linux-amd64
#### wget https://dl.grafana.com/oss/release/grafana-5.4.2-1.x86_64.rpm 
#### sudo yum localinstall grafana-5.4.2-1.x86_64.rpm 
####
if [ \! -d $DIR ]; then
    RPMFILE=grafana-${RELEASE}.x86_64.rpm
    URL="https://dl.grafana.com/oss/release/$RPMFILE"
    wget -O $RPMFILE $URL && yum localinstall $RPMFILE
    if [ $? != 0 ]; then
	echo "Download of grafana failed"
	exit 1
    fi
fi

# cp prometheus datasource
. /etc/Tamedia
sed s/\$PROMETHEUSADDRESS/$PROMETHEUSADDRESS/g datasource_prometheus.yaml > /etc/grafana/provisioning/datsources/prometheus.yaml
# Set start-stop script
chkconfig --add grafana-server
service grafana-server start

