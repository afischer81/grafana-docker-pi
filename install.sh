#!/bin/bash

IMAGE=grafana-fischer

function do_build {
    docker build \
        --build-arg "GRAFANA_VERSION=latest" \
        --build-arg "GF_INSTALL_IMAGE_RENDERER_PLUGIN=true" \
        --build-arg "GF_INSTALL_PLUGINS=briangann-gauge-panel,btplc-trend-box-panel,grafana-clock-panel,grafana-piechart-panel,grafana-simple-json-datasource,mtanda-histogram-panel,pmm-singlestat-panel,vonage-status-panel" \
        -t ${IMAGE} \
        -f Dockerfile .
}

function do_init {
    if [ ! -d /usr/local/etc ]
    then
        mkdir /usr/local/etc
    fi
    sudo install -c -m 644 grafana.ini /usr/local/etc/grafana.ini
    GRAFANA_STORAGE=$(docker volume ls -q --filter "name=grafana-storage")
    if [ "${GRAFANA_STORAGE}" = "" ]
    then
        docker volume create grafana-storage
    fi
}

function do_restart {
    do_stop
    sleep 5
    do_start
}

function do_start {
    docker run -d \
        -p 3000:3000 \
        -v /usr/local/etc/grafana.ini:/etc/grafana/grafana.ini \
        -v grafana-storage:/var/lib/grafana \
        --name=grafana \
        --restart unless-stopped \
        ${IMAGE}
}

function do_stop {
    docker rm -f grafana
}

function do_shell {
    docker exec -it grafana /bin/bash
}

function do_test {
    curl -G http://192.168.137.80:3000/
}

function do_update {
    do_stop
    sleep 5
    do_init
    do_start
}

task=$1
shift
do_$task $*
