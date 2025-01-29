#!/bin/bash

RED='\e[31m'
GREEN='\e[32m'
BLUE='\e[34m'
BOLD='\e[1m'
RESET='\e[0m'

init(){
    echo -e "${BLUE}INFO:${RESET} Inisialisasi..."
    {
        apt update
        apt install wget -y
    } &
    spinner $!
    echo -e "${GREEN}Sukses:${RESET} Inisialisasi berhasil."
}

spinner() {
    local pid=$1
    local delay=0.1
    local spin='-\|/'

    while ps -p $pid > /dev/null 2>&1; do
        for i in $(seq 0 3); do
            echo -ne "\r[${spin:$i:1}] Loading..."
            sleep $delay
        done
    done
    echo -ne "\r[✔] Selesai!      \n"
}


installndbdata(){
    echo -e "${BLUE}INFO:${RESET} Menginstall ndb data node echo Menginstall ndb data node "
    {
    wget https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-common_8.4.3-1debian12_amd64.deb
    apt install ./mysql-common_8.4.3-1debian12_amd64.deb
    wget wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-client-plugins_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-client-plugins_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-client-core_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-client-core_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-client_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-client_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-client_8.4.3-1debian12_amd64.deb
    apt install ./mysql-client_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-server-core_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-server-core_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-server_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-server_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-server-debug_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-server-debug_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-server_8.4.3-1debian12_amd64.deb
    apt install ./mysql-server_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-data-node_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-data-node_8.4.3-1debian12_amd64.deb

    mkdir -p /var/lib/mysql/
    chown -R mysql:mysql /var/lib/mysql/

cat > /etc/systemd/system/ndbd.service <<EOF
[Unit]
Description=MySQL NDB Data Node Daemon
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndbd
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable ndbd
    } &
    spinner $!
    echo -e "${GREEN}Sukses:${RESET} Instalasi berhasil."

}

installndbmgm(){
    echo -e "${BLUE}INFO:${RESET} Menginstall ndb management node echo Menginstall ndb data node "
    {
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-management-server_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-management-server_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-management-client_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-management-client_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-management-server-debug_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-management-server-debug_8.4.3-1debian12_amd64.deb
    wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.4/mysql-cluster-community-management-client-plugins_8.4.3-1debian12_amd64.deb
    apt install ./mysql-cluster-community-management-client-plugins_8.4.3-1debian12_amd64.deb

    mkdir -p /var/lib/mysql-cluster/
    chown -R mysql:mysql /var/lib/mysql-cluster/

cat > /etc/systemd/system/ndb_mgmd.service <<EOF
[Unit]
Description=MySQL NDB Cluster Management Server
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndb_mgmd -f /usr/mysql-cluster/config.ini
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat > /usr/mysql-cluster/config.ini <<EOF   
[ndbd default]
# Options affecting ndbd processes on all data nodes:
NoOfReplicas=2  # Number of replicas

[ndb_mgmd]
# Management process options:
hostname=192.168.221.132  # Hostname of the Management NOde
datadir=/usr/mysql-cluster  # Directory for the log files

[ndbd]
hostname=192.168.221.133  # Hostname/IP of the first data node
NodeId=2  # Node ID for this data node
datadir=/var/lib/mysql/  # Remote directory for the data files

[ndbd]
hostname=192.168.221.134  # Hostname/IP of the second data node
NodeId=3  # Node ID for this data node
datadir=/var/lib/mysql/  # Remote directory for the data files

[mysqld]
NodeId=4
hostname=192.168.221.133 #SQL Node 1

[mysqld]
NodeId=5
hostname=192.168.221.134 #SQL Node 2
EOF
} &
    spinner $!
    echo -e "${GREEN}Sukses:${RESET} Instalasi berhasil. edit /usr/mysql-cluster/config.ini untuk konfigurasi lebih lanjut"
}

while true; do
    clear
    echo -e "${GREEN}=====================================${RESET}"
    echo -e "${GREEN}       MySQL NDB Cluster Setup       ${RESET}"
    echo -e "${GREEN}               by: KW                ${RESET}"
    echo -e "${GREEN}=====================================${RESET}"
    echo -e "${YELLOW}Pilih opsi:${RESET}"
    echo -e "  1) Install NDB Data Node"
    echo -e "  2) Install NDB Cluster Management Server"
    echo -e "  3) Keluar"
    echo -ne "\nMasukkan pilihan Anda (1-3): "

    read -r pilihan

    case $pilihan in
        1)
            echo -e "${YELLOW}Menjalankan instalasi NDB Data Node...${RESET}"
            init
            installndbdata  # Panggil fungsi instalasi
            read -rp "Tekan [Enter] untuk kembali ke menu..."
            ;;
        2)
            echo -e "${YELLOW}Menjalankan instalasi NDB Cluster Management Server...${RESET}"
            init
            installndbmgm  # Panggil fungsi instalasi
            read -rp "Tekan [Enter] untuk kembali ke menu..."
            ;;
        3)
            echo -e "${RED}Keluar...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid! Silakan pilih antara 1-3.${RESET}"
            sleep 2
            ;;
    esac
done
