#/bin/bash

FILE="/root/ipfile"         # Update File Path
JAILFILE="/etc/fail2ban/jail.local"
# # For Testing you may uncomment below Loop
# for i in {1..100}
# do
#     echo "192.168.1.$i" >> ipfile
# done

# Setting $JAILFILE file to Defail Value
sed -i "/ignoreip/d" $JAILFILE
sed -i "/\[DEFAULT\].*/aignoreip = 127.0.0.1\/8" $JAILFILE


for i in $(cat $FILE)
do 
    # echo "IP Address line by Line : ${i[@]}"
    # sleep 1
    sed -i "s/127.0.0.1\/8/& ${i[@]}/" $JAILFILE
done
