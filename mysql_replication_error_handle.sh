while [ 1 ]; do 
    if [ $(mysql -uroot --password='repl!c@t!0n_d@t@b@$e' -e"show slave status \G;" | grep "Duplicate entry" | wc -l) -eq 2 ] ; then 
        mysql -uroot --password='repl!c@t!0n_d@t@b@$e' -e"stop slave; set global slave_exec_mode = 'idempotent'; set global sql_slave_skip_counter=1; start slave;"; 
    fi; 
    sleep 1; 
    mysql -uroot --password='repl!c@t!0n_d@t@b@$e' -e "show slave status\G"; 
done


SET GTID_NEXT="cbab1643-b20f-11ea-bfd3-005056a1f1b9:1-15";
BEGIN;
COMMIT;
SET GTID_NEXT='AUTOMATIC';
start slave;
show slave status\G;

set global GTID_PURGED="cbab1643-b20f-11ea-bfd3-005056a1f1b9:1-15";
set global GTID_PURGED="44a52a4b-b545-11ea-ad7b-005056a1194b:1-22";
start slave io_thread;
show slave status\G;
