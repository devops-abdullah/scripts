<?php
/*** process asterisk cdr file (Master.csv) insert usage
* values into a mysql database which is created for use
* with the Asterisk_addons cdr_addon_mysql.so
* The script will only insert NEW records so it is safe
* to run on the same log over-and-over.
*
* Author: John Lange (john@johnlange.ca)
* Date: Version 2 Released July 8, 2008
*
* Here is what the script does:
*
* Parse each row from the text log and insert it into the database after testing for a
* matching "calldate, src, duration" record in the database. Note that not all fields are
* tested.
*
* If you have a large existing database it is recommended that you add an index to the calldate
* field which will greatly speed up this import.
*
*/
/*
 * Modified by kiba, December 1, 2016 to migrate to mysqli
 * Modified by Leif Madsen, July 29, 2009 to add additional columns.
 * Original post and code by John Lange: http://www.johnlange.ca/tech-tips/asterisk/asterisk-cdr-csv-mysql-import-v20/
 */

$db_host = 'localhost';
$db_name = 'yovo_db_cc';
$db_login = 'intellicon';
$db_pass = 'intellicon';

if($argc == 2) {
  $logfile = $argv[1];
} else {
  print("Usage ".$argv[0]." <filename>\n");
  print("Where filename is the path to the Asterisk csv file to import (Master.csv)\n");
  print("This script is safe to run multiple times on a growing log file as it only imports records that are newer than the database\n");
  exit(0);
}

// connect to db
$mysqli = new mysqli($db_host, $db_login, $db_pass, $db_name); 
if ($mysqli->connect_errno) {
  die("Could not connect : " . $mysqli->connect_error());
}

//** 1) Find records in the asterisk log file. **
$rows = 0;
$handle = fopen($logfile, "r");
while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
  // NOTE: the fields in Master.csv can vary. This should work by default on all installations but you may have to edit the next line to match your configuration
    list($accountcode, $src, $dst, $dcontext, $clid, $channel, $dstchannel, $lastapp, 
         $lastdata, $start, $answer, $end, $duration, $billsec, $disposition, $amaflags, $uniqueid, $userfield ) = $data;
  /** 2) Test to see if the entry is unique **/
  $sql = "SELECT calldate, src, duration".
  " FROM yovo_tbl_cdrs_copy".
  " WHERE calldate='$start'".
  " AND src='$src'".
  " AND duration='$duration'".
  " LIMIT 1";
  if(!($result = $mysqli->query($sql))) {
    print("Invalid query: " . mysqli_error()."\n");
    print("SQL: $sql\n");
    die();
  }
  if($result->num_rows === 0) { // we found a new record so add it to the DB
    // 3) insert each row in the database
        if ($answer === '') $answer = '0000-00-00 00:00:00';  // replace empty date with default value
        $sql = "INSERT INTO yovo_tbl_cdrs_copy (calldate,
                                 clid,
                                 src,
                                 dst,
                                 dcontext,
                                 channel,
                                 dstchannel,
                                 lastapp,
                                 lastdata,
                                 duration,
                                 billsec,
                                 disposition,
                                 amaflags,
                                 accountcode,
                                 uniqueid,
                                 userfield) 
            VALUES('$start',
                '".$mysqli->escape_string($clid)."',
                '$src',
                '$dst',
                '$dcontext',
                '$channel',
                '$dstchannel',
                '$lastapp',
                '$lastdata',
                '$duration',
                '$billsec',
                '$disposition',
                '$amaflags',
                '$accountcode',
                '$uniqueid', 
                '$userfield')";
    if(!($result2 = $mysqli->query($sql))) {
      print("Invalid query: " . $mysqli->error."\n");
      print("SQL: $sql\n");
      continue; // skip invalid record or you can die() here
    }
    print("Inserted: $end $src $duration\n");
    $rows++;
  } else {
    print("Not unique: $end $src $duration\n");
  }
}

$result->free();
$result2->free();
$mysqli->close();

fclose($handle);
print("$rows imported\n");
?>
