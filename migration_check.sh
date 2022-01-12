#!/bin/bash

#######################################
#     Author: Abdullah Manzoor
#######################################

### Node Directory
dir=/migrations

function runmigration(){
set -e  #Incase of any error this script will exit automatically
		cd $dir &&  \
        npx sequelize db:migrate:status --config config/index.js --env mysql && \
        cd $dir  &&  \
        npx sequelize db:migrate --config config/index.js --env mysql && \
        sleep 2 && \
        cd $dir  &&  \
        npx sequelize db:migrate:status --config config/index.js --env mysql && \
        sleep 2 && \
        cd $dir  &&  \
        npx sequelize db:seed:all --config config/index.js --env mysql

set +e
}
echo "******************** Running migrations"
runmigration
