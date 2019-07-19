#!/bin/bash
# Installation script of Grafana from rpm
# x.y.z = release

# Define installation directory
DIR=grafana-$GRAFANA_RELEASE.linux-amd64
# Install if not already installed
if ! rpm -q grafana;  then
    RPMFILE=grafana-${GRAFANA_RELEASE}.x86_64.rpm
    URL="https://dl.grafana.com/oss/release/$RPMFILE"
    yum install -y $URL
    if [ $? != 0 ]; then
	echo "Installation of $URL failed"
	exit 1
    fi
    

    # cp prometheus datasource
    . /etc/myawsenv
    CURDIR=$(dirname $0)
    S=aws secretsmanager get-secret-value --secret-id ${GRAFANADATASOURCESECRECT} --region ${AWS::Region} --query SecretString --output text
    sed s/\$PROMETHEUSADDRESS/$PROMETHEUSADDRESS/g $CURDIR/datasource_prometheus.yaml > /etc/grafana/provisioning/datasources/prometheus.yaml
    sed -i s/\$GRAFANADATASOURCEUSER/$GRAFANADATASOURCEUSER/g /etc/grafana/provisioning/datasources/prometheus.yaml
    sed -i s/\$GRAFANADATASOURCEPASS/$S/g /etc/grafana/provisioning/datasources/prometheus.yaml
    chmod 600 /etc/grafana/provisioning/datasources/prometheus.yaml
    # Set start-stop script
    /bin/systemctl daemon-reload
    /bin/systemctl enable grafana-server.service
    #chkconfig --add grafana-server
    #service grafana-server start
    
    #Plugins
    # plugin: alertmanager (required for use alertmanager as datasource)
    grafana-cli plugins install camptocamp-prometheus-alertmanager-datasource
    # Plugin status Panel, required by David, installed 19.07.2019
    grafana-cli plugins install vonage-status-panel
    service grafana-server restart

else
    echo "Grafana already installed: Nothing done"
fi


