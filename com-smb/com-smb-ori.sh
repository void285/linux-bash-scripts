#!/bin/bash
# set some vars
alladmin=""
q10=10445760
q12=12582912
q20=20971520
hosts="hosts allow = 166.111.119.128/255.255.255.128 166.111.107.224/255.255.255.224 59.66.97.43"
touch smb.conf
> smb.conf
rootdir="/data/samba/cae"
# set the sharedir
sharedir="${rootdir}/共享"
pubdir="${rootdir}/共享/公共"
temdir="${rootdir}/共享/公共/临时"
archdir="${rootdir}/共享/公共/归档"
readme="${sharedir}/README.txt"
mkdir ${sharedir}
echo "The directory ${sharedir} created."
mkdir ${pubdir}
echo "The directory ${pubdir} created."
mkdir ${temdir}
echo "The directory ${temdir} created."
mkdir ${archdir}
echo "The directory ${archdir} created."
chown -R admin.admin ${sharedir}
chmod -R 0775 ${sharedir}
cp note.txt ${readme}
chown root.root ${readme}
chmod 644 ${readme}
# set accounts and department dir
while read line
do
	# vars
	name=$(echo ${line} | cut -d ";" -f 1)
	dname=$(echo ${line} | cut -d ";" -f 2)
	rdname=${rootdir}/${dname}
	sdname=${sharedir}/${dname}
	# add accounts
	useradd -s /sbin/nologin ${name}admin > /dev/null
	echo "User ${name}admin added."
	useradd -g ${name}admin -s /sbin/nologin ${name}user > /dev/null
	echo "User ${name}user added."
	printf "4${name}admin\n4${name}admin\n" | smbpasswd -a -s ${name}admin > /dev/null
	echo "User ${name}admin added to smbpasswd, and the passwd is 4${name}admin."
	printf "4${name}user\n4${name}user\n" | smbpasswd -a -s ${name}user > /dev/null
	echo "User ${name}user added to smbpasswd, and the passwd is 4${name}user."
	# dirs
	cd ${rootdir}
	mkdir ${dname}
	echo "The directory ${rdname} created."
	chown ${name}admin.${name}admin ${dname}
	chmod 1770 ${dname}
	mkdir ${sdname}
	echo "The directory ${sdname} created."
	chown ${name}admin.${name}admin ${sdname}
	chmod 1775 ${sdname}
	# readme
	dreadme=${dname}/README.txt
	cp ${readme} ${dreadme}
	chown root.root ${dreadme}
	chmod 644 ${dreadme}
	# quota
	setquota -u ${name}admin ${q10} ${q12} 0 0 /data
	setquota -u ${name}user ${q10} ${q12} 0 0 /data
	alladmin="${alladmin},@${name}admin"
	# generate smb.conf
	cd - > /dev/null
	echo "[${dname}]" >> smb.conf
	echo "comment = ${dname}部门专用目录" >> smb.conf
	echo "available = yes" >> smb.conf
	echo "path = ${rdname}" >> smb.conf
	echo "browseable = no" >> smb.conf
	echo "writable = yes" >> smb.conf
	echo "public = no" >> smb.conf
	echo "${hosts}" >> smb.conf
	echo "admin users = ${name}admin" >> smb.conf
	echo "valid users = @${name}admin" >> smb.conf
	echo "create mask = 0750" >> smb.conf
	echo "directory mask = 0750" >> smb.conf
	echo "" >> smb.conf
done < com-smb.txt
# generate smb.conf
echo "[共享]" >> smb.conf
echo "comment = 各部门公用目录" >> smb.conf
echo "available = yes" >> smb.conf
echo "path = ${sharedir}" >> smb.conf
echo "browseable = no" >> smb.conf
echo "writable = yes" >> smb.conf
echo "public = no" >> smb.conf
echo "${hosts}" >> smb.conf
echo "valid users = admin${alladmin}" >> smb.conf
echo "create mask = 0755" >> smb.conf
echo "directory mask = 0755" >> smb.conf
echo "The reletive config context generated and put in the smb.conf file."
cp smb.conf /etc/samba/com-smb.conf
echo "include = /etc/samba/com-smb.conf" >> /etc/samba/smb.conf
echo "The smb.conf file appended to /etc/samba/smb.conf."
# all done
echo "All done! Plz restart the smbd/nmbd server."
