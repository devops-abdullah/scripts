#!/bin/bash
clear
_sngrep(){
echo "Author:	Abdullah Manzoor"
echo "Email: 	abdullah.itdeft@gmail.com"
echo "[SNGREP] Preparing"
if  rpm -qa | grep 'sngrep-*'; then
   echo "[SNGREP] Already installed, exiting....!!!"
else
   echo "[SNGREP] Adding repositories"
	if [ -f /etc/yum.repos.d/sngrep.repo ]; then
	echo "Repo file is already exist"
	else
	touch /etc/yum.repos.d/sngrep.repo
echo '[irontec]
name=Irontec RPMs repository
baseurl=http://packages.irontec.com/centos/$releasever/$basearch/' >> /etc/yum.repos.d/sngrep.repo
	echo "Repo has been created successfully"
	rpm --import http://packages.irontec.com/public.key
	yum clean metadata
	yum clean dbcache
	yum makecache fast
    yum install -y sngrep
    echo "[SNGREP] Installed"
	rm -rf /etc/yum.repos.d/sngrep.repo
  fi
fi
}
_sngrep
