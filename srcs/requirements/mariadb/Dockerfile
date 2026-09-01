FROM alpine:3.24

RUN apt-get update && apt-get install -y mariadb mariadb-server
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

EXPOSE 3306

COPY ./entrypoint.sh  /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["mysqld", "--user=mmysql", "--console" ]
