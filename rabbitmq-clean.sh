#!/bin/bash

################################################################################
# Author: Abdullah Manzoor
# Email: abdullah.itdeft@gmail.com
################################################################################

################################################################################
# DISCLAIMER
################################################################################
# The following Bash script is provided "as-is" without any warranty. Use it at
# your own risk. The author and contributors disclaim all liability for direct,
# indirect, or consequential damages resulting from your use of this script.
# 
# Before executing this script, ensure that you have reviewed and understood its
# functionality. Make sure to back up your data and system configuration before
# running the script, as it may modify or delete files and settings.
#
# This script may require administrative privileges for certain operations. 
# Always run scripts from trusted sources, and only execute them in environments
# where you have the necessary permissions.
#
# The author and contributors are not responsible for any data loss, system
# instability, or any other issues that may arise from the use of this script.
#
# If you have any concerns or questions about this script, please contact the
# author or seek assistance from relevant forums or communities.
################################################################################

################################################################################
# This Script will Remove the Queues from Rabbitmq Server.
################################################################################

DIR=/tmp
CMD="rabbitmqctl"
QList="queueList.txt"
CList="consumerList.txt"
DList="deleteQueueList.txt"


function prepareQList() {
  # Below command will list all the Queue those are with Zero (0) message count...!!!
  $CMD list_queues | awk '$2==0{print$1}' > $DIR/$QList
  echo "Queues List has been Prepared under TMP Folder: $DIR/$QList"
}

function prepareCList() {
  # Below command will list the Queue with consumers connection
  # Later on we'll use this list with queueList to get the Queues without any 
  # consumers to cleanup the Rabbitmq extra queue
  $CMD list_consumers | awk '{print f $1}' > $DIR/$CList
  echo "Consumers Queue List has been Prepared under TMP Folder: $DIR/$CList"
}

function prepareDList() {
  # Below command will compare the Queue List and consumerList to filter the Queues without consumers connection
  diff -y -W 100 --suppress-common-lines $DIR/$QList $DIR/$CList | awk '{print f $1}' > $DIR/$DList
  echo "Delete Queue List has been Prepared under TMP Folder: $DIR/$DList"
}

function prepareList() {
  # Below command will remove the Fist 2 line from File those are not required
  echo "Delete Unrequired Lines from File"
  sed -i '1,2d' $DIR/$DList
  
  # Below command will show the Total Number of Queue in File
  echo "Total Queue in File : `cat $DIR/$DList | wc -l`"
}

function cleanTmpFiles() {
  # below command will remove the Files from System
  rm -rf $DIR/$DList $DIR/$QList $DIR/$CList
}

function cleanUpRabbit() {
  # Below command will get all the lines from deleteQueueList.txt
  list=(`cat $DIR/$DList`)

  # For Loop to Delete all the Queues in List
  for i in ${list[@]};
  do
          echo "Deleting Queue: $i"
          $CMD delete_queue $i
  done
}

function __main() {
  prepareQList
  prepareCList
  prepareDList
  prepareList
#  cleanUpRabbit
#  cleanTmpFiles
}

__main
