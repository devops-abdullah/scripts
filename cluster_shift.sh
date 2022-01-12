#!/bin/bash

echo "Author        :   Abdullah Manzoor"
echo "Company       :   Contegris Pvt. Ltd"
echo "Department    :   Infrastructure & DevOps"

SERVER1='1.1.1.2'
SERVER2='1.1.1.3'
SERVER3='1.1.1.4'

if [[ "$1" == "SERVER1" || "$1" == "SERVER2" || "$1" == "SERVER3" ]]; then
        echo "good"
        if [ "$1" == "SERVER1" ]; then
        #ssh $SERVER1 "pm2 $2 all && systemctl $2 asterisk"
        echo "SERVER1"
        elif [ "$1" == "SERVER2" ]; then
        #ssh $SERVER2 "pm2 $2 all && systemctl $2 asterisk"
        echo "SERVER2"
        elif [ "$1" == "SERVER3" ]; then
        #ssh $SERVER3 "pm2 $2 all && systemctl $2 asterisk"
        echo "SERVER3"
        fi
        else
        echo "Please mention SERVER1,SERVER2,SERVER3 as argument start/stop as second argument"
fi
