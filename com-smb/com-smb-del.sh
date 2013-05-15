#!/bin/bash
rootdir="/data/samba/cae"
rm -rf ${rootdir}/*
echo "All files and directories under ${rootdir} deleted."
while read line
do
	name=$(echo ${line} | cut -d ";" -f 1)
	smbpasswd -x ${name}admin > /dev/null
	echo "User ${name}admin deleted from smbpasswd."
	smbpasswd -x ${name}user > /dev/null
	echo "User ${name}user deleted from smbpasswd."
	userdel ${name}admin > /dev/null 2>&1
	echo "User ${name}admin deleted."
	userdel ${name}user > /dev/null
	echo "User ${name}user deleted."
	groupdel ${name}admin > /dev/null
	echo "Group ${name}admin deleted."
done < com-smb.txt
rm /etc/samba/com-smb.conf
echo "The file /etc/samba/com-smb.conf deleted."
sed -i '/^include \= \/etc\/samba\/com-smb\.conf$/d' /etc/samba/smb.conf
echo "The include line added to /etc/samba/smb.conf deleted."
echo "All done! Plz restart the smbd/nmbd service."
