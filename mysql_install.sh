#!/bin/bash

TAR_NAME="mysql-8.0.26.tar.xz"

INSTALL_DIR="/usr/local/mysql"
DATA_DIR="/usr/local/mysql/data"

MYSQL_GROUP="mysql"
MYSQL_USER="mysql"

# check tar file
if [ ! -f ${TAR_NAME} ]; then
  wget -c https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.26-linux-glibc2.17-x86_64-minimal-rebuild.tar.xz -O ${TAR_NAME}
fi
echo "check tar file ... ok"

# check user&group
id -u ${MYSQL_USER} &>/dev/null
if [ $? -ne 0 ]; then
  groupadd ${MYSQL_GROUP}
  useradd -g ${MYSQL_GROUP} -s /sbin/nologin -d /home/${MYSQL_USER} ${MYSQL_USER}
fi
echo "check mysql user ... ok"

# check install dir
[ ! -d "${INSTALL_DIR}" ] && mkdir -p ${INSTALL_DIR}
[ ! -d "${DATA_DIR}" ] && mkdir -p ${DATA_DIR}

chown -R root ${INSTALL_DIR}
chown -R mysql:mysql ${INSTALL_DIR}
chown -R mysql:mysql ${DATA_DIR}
echo "check install dir ... ok"

# untar file
tar -xf ${TAR_NAME} -C ${INSTALL_DIR} --strip-components 1
echo "untar file ... ok"

# init db and config
${INSTALL_DIR}/bin/mysqld --initialize-insecure --user=${MYSQL_USER} --basedir=${INSTALL_DIR} --datadir=${DATA_DIR}
[ $? -ne 0 ] && exit 1
cp ${INSTALL_DIR}/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
echo "init database ... ok"

# init my.cnf
[ -f /etc/my.cnf ] && mv /etc/my.cnf{,.ori}
cat >>/etc/my.cnf <<EOF
[client]
port= 3306
default-character-set=utf8
[mysql]
default-character-set=utf8
[mysqld]
port= 3306
server-id = 1
EOF
echo "init my.cnf ... ok"
