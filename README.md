# vagrant-zabbix


## start vms

```bash
vagrant up z1 z2 z3 z4
```

| vm | ip            | install                                       |
|----|---------------|-----------------------------------------------|
| z1 | 192.168.28.21 | docker, zabbix-server, zabbix-web, postgres14 |
| z2 | 192.168.28.22 | docker, zabbix-agent                          |
| z3 | 192.168.28.23 | docker, zabbix-agent                          |
| z4 | 192.168.28.24 | docker, zabbix-agent                          |


## deploy-zabbix

```bash
vagrant ssh z1
su -
cd /vagrant
bash ./install-zabbix-server.sh
```

```bash
vagrant ssh z2
su -
cd /vagrant
bash ./install-zabbix-agent.sh
```

```bash
vagrant ssh z3
su -
cd /vagrant
bash ./install-zabbix-agent.sh
```

```bash
vagrant ssh z4
su -
cd /vagrant
bash ./install-zabbix-agent.sh
```

## use-zabbix

Open browser http://192.168.28.21:20080

默认账号：Admin，密码：zabbix，这是一个超级管理员。