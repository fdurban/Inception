#!/bin/sh

sed -i "s|*.bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf

if [ ! -d /var/lib/mysql/mysql ] ; then
	echo "Data directory empy... Initializing MariaDB";
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

	mysqld --user=mysql --datadir=/var/lib/mysql  --skip-networking  &
	pid="$!"
	
	while ! mysqladmin ping --silent; do
		sleep 1
	done

	mysql -u root <<-EOSQL
		CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
		FLUSH PRIVILEGES;
EOSQL

	mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown
	wait"$pid"

	echo "Mariadb initialization completed"

fi

exec "$@"
