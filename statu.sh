#!/bin/bash
echo ""
echo "============================================================="
echo "            <<  Welcome     "
echo "============================================================="
echo "Username..........: $USER"
echo "              *******************************"
echo "============================================================="
echo "$(cat /etc/redhat-release)"
echo "Total Memory              | $(free -h | grep -i Mem | awk '{print $2}')"
echo "Available Memory          | $(free -h | grep -i Mem | awk '{print $7}')"
echo "Disk Size                 | $(df -h | grep -i root | awk '{print $2}')"
echo "Free Disk Size            | $(df -h | grep -i root | awk '{print $4}')"
echo "Up Time                   | $(uptime | awk '{print $1,$2,$3,$4,$5,$6}')"
echo "System Clock              | $(date)"
echo "Hardware Clock            | $(hwclock)"
echo "                 *******************************"
echo "                      << Voice Services Status "
echo "                 *******************************"
echo "Asterisk Status           | $(systemctl status asterisk | grep Active | awk $'{print $2}')"
echo "AgiSpeedy Status          | $(systemctl status agispeedy | grep Active | awk $'{print $2}')"
echo "OpenSips Status           | $(systemctl status opensips | grep Active | awk $'{print $2}')"
function stun() {
service=$(ps -ef | grep -v grep | grep turnserver | wc -l)
 if (( $service > 0 ))
 then
echo "TurnServer Status         | Active"
        else
echo "TurnServer Status         | Inactive"
        fi
}
stun
echo "RTP-Egine Status          | $(systemctl status rtpengine.service | grep Active | awk $'{print $2}')"
echo "                 *******************************"
echo "                      << Services Status "
echo "                 *******************************"
echo "MySQL Status       | $(systemctl status mysqld | grep Active | awk $'{print $2}')"
echo "RABBITMQ Status    | $(systemctl status rabbitmq-server.service | grep Active | awk $'{print $2}')"
echo "Redis Status       | $(systemctl status redis | grep Active | awk $'{print $2}')"
echo "Apache Status      | $(systemctl status httpd | grep Active | awk $'{print $2}')"
echo "Network Status     | $(systemctl status network | grep Active | awk $'{print $2}')"
echo "Monit Status       | $(systemctl status monit | grep Active | awk $'{print $2}')"
echo "NTP Status         | $(systemctl status ntpd | grep Active | awk $'{print $2}')"
