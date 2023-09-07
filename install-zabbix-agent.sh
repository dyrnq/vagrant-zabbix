#!/usr/bin/env bash


# https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=22.04&components=agent&db=&ws=



pushd /tmp || exit 1;
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt update


apt install zabbix-agent -y

sed -i "s|^Server=.*|Server=192.168.28.21|g" /etc/zabbix/zabbix_agentd.conf
sed -i "s|^ServerActive=.*|ServerActive=192.168.28.21|g" /etc/zabbix/zabbix_agentd.conf

systemctl zabbix-agent
if systemctl is-active zabbix-agent &>/dev/null; then
    systemctl restart zabbix-agent
else
    systemctl enable --now zabbix-agent 
fi
systemctl status -l zabbix-agent --no-pager

popd || exit 1