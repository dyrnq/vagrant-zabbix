#!/usr/bin/env bash


command_exists() {
    command -v "$@" > /dev/null 2>&1
}

_debian() {
    apt update && \
    apt install -y apt-transport-https curl iptables wget vim psmisc procps iproute2 tree jq gnupg2 netcat nmap htop locales gettext difference ca-certificates openssh-client unzip less ipset net-tools ipvsadm xz-utils conntrack xfsprogs

    apt install autofs nfs-common numactl -y
    
}

_centos() {
    yum update -y && \
    yum install -y nc nfs-utils unzip tree ca-certificates traceroute iptables-nft whois psmisc bc nmap openssh-server lsof net-tools curl wget git vim jq socat conntrack ipvsadm ipset sysstat libseccomp bzip2 libtool flex bison pcre-devel zlib-devel openssl openssl-devel bind-utils libnl3 libnl3-devel systemd-devel libuuid-devel device-mapper-persistent-data lvm2 && \
    yum install epel-release -y && \
    yum install -y htop bridge-utils

    ## Command line error: no such option: --allowerasing

    yum install -y autofs nfs-common numactl
}


if command_exists apt > /dev/null; then

    if grep ID=debian < /etc/os-release ; then
        sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
        sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
    fi

    if grep ID=ubuntu < /etc/os-release ; then
        sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list
    fi

_debian
fi

if command_exists yum > /dev/null; then
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.ustc.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-Base.repo
_centos         
fi






## 设置时区

timedatectl set-timezone "Asia/Shanghai"

## 关闭防火墙

systemctl is-active firewalld >/dev/null 2>&1 && systemctl disable --now firewalld
systemctl is-active dnsmasq >/dev/null 2>&1 && systemctl disable --now dnsmasq
systemctl is-active apparmor >/dev/null 2>&1 && systemctl disable --now apparmor
systemctl is-active ufw >/dev/null 2>&1 && systemctl disable --now ufw

## 关闭swap

#sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab

## 关闭selinux

if [ -f /etc/selinux/config ]; then sed -i.bak 's@enforcing@disabled@' /etc/selinux/config; fi
command -v setenforce && setenforce 0
command -v getenforce && getenforce && sestatus

## sysctl设置

cat > /etc/sysctl.d/mysysctl.conf << 'EOF'
fs.file-max = 52706963 
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 1048576
fs.may_detach_mounts = 1
fs.nr_open = 52706963
kernel.core_uses_pid = 1
kernel.msgmax = 65535
kernel.msgmnb = 65535 
kernel.pid_max = 4194303 
kernel.shmall = 4294967296
kernel.shmmax = 68719476736
kernel.softlockup_all_cpu_backtrace = 1
kernel.softlockup_panic = 1
#kernel.sysrq = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.core.netdev_max_backlog = 16384
net.core.rmem_max = 16777216
net.core.somaxconn = 32768
net.core.wmem_max = 16777216
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.all.route_localnet = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.ip_forward = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.neigh.default.gc_thresh1 = 8192
net.ipv4.neigh.default.gc_thresh2 = 32768
net.ipv4.neigh.default.gc_thresh3 = 65536
net.ipv4.tcp_fin_timeout = 20
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_max_orphans = 32768
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_retries2 = 2
net.ipv4.tcp_rmem = 4096 12582912 16777216
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_wmem = 4096 12582912 16777216
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_close = 3
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 12
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.nf_conntrack_max = 25000000
vm.max_map_count = 262144
vm.min_free_kbytes = 262144
vm.overcommit_memory = 1
vm.panic_on_oom = 0
vm.swappiness = 0
EOF


sysctl --system

## limits 修改

cat > /etc/security/limits.conf <<'EOF'
*       soft        core        unlimited
*       hard        core        unlimited
*       soft        nproc       1000000
*       hard        nproc       1000000
*       soft        nofile      1000000
*       hard        nofile      1000000
*       soft        memlock     32000
*       hard        memlock     32000
*       soft        msgqueue    8192000
EOF


## 加载linux内核模块

if ! systemctl is-active systemd-modules-load.service >/dev/null 2>&1; then
    systemctl enable systemd-modules-load.service
fi

cat > /etc/modules-load.d/90-net.conf<<EOF
overlay
br_netfilter
EOF

systemctl daemon-reload && systemctl restart systemd-modules-load.service

lsmod | grep br_netfilter


mkdir -p /etc/systemd/system.conf.d/
cat >/etc/systemd/system.conf.d/limits.conf<<EOF
[Manager]
DefaultTimeoutStopSec=20s
DefaultLimitCORE=infinity
DefaultLimitNOFILE=infinity
DefaultLimitNPROC=infinity
DefaultTasksMax=infinity
DefaultLimitMEMLOCK=infinity
EOF
systemctl daemon-reload
systemctl show --no-pager| grep Limit


