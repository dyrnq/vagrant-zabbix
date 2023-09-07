#!/usr/bin/env bash




iface="${iface:-enp0s8}"
etcd_home="${etcd_home:-$HOME/etcd}"
apisix_home="${apisix_home:-$HOME/apisix}"
apisix_dashboard_home="${apisix_dashboard_home:-$HOME/apisix-dashboard}"
apisix_image="${apisix_image:-apache/apisix:3.4.0-debian}"
apisix_dashboard_image="${apisix_dashboard_image:-apache/apisix-dashboard:3.0.1-alpine}"
etcd_image="${etcd_image:-quay.io/coreos/etcd:v3.5.9}"
wait4x_image="${wait4x_image:-atkrad/wait4x:2.12}"
nginx_image="${nginx_image:-nginx:1.22.1-alpine}"
mysql5_image="${mysql5_image:-mysql:5.7.41}"
mysql8_image="${mysql8_image:-mysql:8.0.23}"
pg_image="${pg_image:-postgres:14.9-bullseye}"
whoami_image="${whoami_image:-containous/whoami:latest}"
adminer_image="${adminer_image:-adminer:4.8.1}"
minio_image="${minio_image:-minio/minio:RELEASE.2022-11-29T23-40-49Z}"


ip4=$(/sbin/ip -o -4 addr list "${iface}" | awk '{print $4}' |cut -d/ -f1 | head -n1);


command_exists() {
    command -v "$@" > /dev/null 2>&1
}


fun_install() {

docker rm -f postgres14 2>/dev/null || true

mkdir -p $HOME/var/lib/postgresql/data

docker run -d --name postgres14 \
--restart always \
--network mynet \
-e POSTGRES_PASSWORD=666666 \
-p 5432:5432 \
-v $HOME/var/lib/postgresql/data:/var/lib/postgresql/data \
${pg_image}


#docker exec -it postgres14 bash -c "ls -lv /tmp; /tmp/wait-for-postgres.sh"


docker rm -f adminer 2>/dev/null || true
docker run -d --name=adminer --restart always --network mynet -p 18080:8080 ${adminer_image}


docker rm -f zabbix-server 2>/dev/null || true
docker run --name zabbix-server \
--restart=always \
--network mynet \
-e DB_SERVER_HOST="postgres14" \
-e DB_SERVER_PORT=5432 \
-e POSTGRES_USER="postgres" \
-e POSTGRES_PASSWORD="666666" \
-e POSTGRES_DB="zabbix" \
-d \
-p 10051:10051 \
zabbix/zabbix-server-pgsql:alpine-6.0.21


docker rm -f zabbix-web 2>/dev/null || true
docker run --name zabbix-web \
--restart=always \
--network mynet \
-e DB_SERVER_HOST="postgres14" \
-e DB_SERVER_PORT=5432 \
-e POSTGRES_USER="postgres" \
-e POSTGRES_PASSWORD="666666" \
-e POSTGRES_DB="zabbix" \
-e ZBX_SERVER_HOST="192.168.28.21" \
-e ZBX_SERVER_PORT=10051 \
-e PHP_TZ="Asia/Shanghai" \
-d \
-p 20080:8080 \
-p 20443:8443 \
zabbix/zabbix-web-nginx-pgsql:alpine-6.0.21

}

fun_add_mynet(){

docker network inspect mynet &>/dev/null || docker network create --subnet 172.18.0.0/16 --gateway 172.18.0.1 --driver bridge mynet

}


fun_add_mynet

fun_install

echo "#默认账号：Admin，密码：zabbix，这是一个超级管理员。"