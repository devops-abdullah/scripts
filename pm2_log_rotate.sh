#!/bin/bash

pm2 install pm2-logrotate

#To install a specific version use the @<version> suffix
#pm2 install pm2-logrotate@2.2.0

#Configure
#max_size (Defaults to 10M): When a file size becomes higher than this value it will rotate it (its possible that the worker check the file after it actually pass the limit) . You can specify the unit at then end: 10G, 10M, 10K
#retain (Defaults to 30 file logs): This number is the number of rotated logs that are keep at any one time, it means that if you have retain = 7 you will have at most 7 rotated logs and your current one.
#compress (Defaults to false): Enable compression via gzip for all rotated logs
#dateFormat (Defaults to YYYY-MM-DD_HH-mm-ss) : Format of the data used the name the file of log
#rotateModule (Defaults to true) : Rotate the log of pm2's module like other apps
#workerInterval (Defaults to 30 in secs) : You can control at which interval the worker is checking the log's size (minimum is 1)
#rotateInterval (Defaults to 0 0 * * * everyday at midnight): This cron is used to a force rotate when executed. We are using node-schedule to schedule cron, so all valid cron for node-schedule is valid cron for this option. Cron style :
#TZ (Defaults to system time): This is the standard tz database timezone used to offset the log file saved. For instance, a value of Etc/GMT-1, with an hourly log, will save a file at hour 14 GMT with hour 13 GMT-1 in the log name.


#How to set these values ?
#After having installed the module you have to type : pm2 set pm2-logrotate:<param> <value>
#e.g:

#pm2 set pm2-logrotate:max_size 1K (1KB)
#pm2 set pm2-logrotate:compress true (compress logs when rotated)
#pm2 set pm2-logrotate:rotateInterval '*/1 * * * *' (force rotate every minute)


pm2 set pm2-logrotate:max_size 20M
pm2 set pm2-logrotate:compress true
#pm2 set pm2-logrotate:rotateInterval '0 0 * * *'  # Defaults every day at midnight no need to configure
#pm2 set pm2-logrotate:dateFormat YYYY-MM-DD_HH-mm-ss 	#Default Value
#pm2 set pm2-logrotate:retain 30						#Defaults to 30 file logs it means that if you have retain = 30 you will have at most 30 rotated logs and your current one
#pm2 set pm2-logrotate:rotateModule						#Defaults to true
pm2 set pm2-logrotate:workerInterval 1					#Defaults to 30 in secs
