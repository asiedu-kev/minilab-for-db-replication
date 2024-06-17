#!/bin/bash

# Source the .env file to load environment variables
set -a
source .env
set +a

docker-compose down -v
rm -rf ./master/data/*
rm -rf ./slave/data/*
docker-compose build
docker-compose up -d

until docker exec mysql_master sh -c 'export MYSQL_PWD=password; mysql -u root  -ppassword -e ";"'
do
    echo "Waiting for mysql_master database connection..."
    sleep 4
done

priv_stmt='CREATE USER "sail_slave"@"%" IDENTIFIED BY "password_0"; GRANT REPLICATION SLAVE ON *.* TO "sail_slave"@"%"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=password; mysql -u root -ppassword -e '$priv_stmt'"

until docker exec mysql_slave sh -c 'export MYSQL_PWD=password; mysql -u root  -ppassword -e ";"'
do
    echo "Waiting for mysql_slave database connection..."
    sleep 4
done

MS_STATUS=`docker exec mysql_master sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='mysql_master',MASTER_USER='sail_slave',MASTER_PASSWORD='password_0',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
docker exec mysql_slave sh -c "$start_slave_cmd"

docker exec mysql_slave sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"


#s
