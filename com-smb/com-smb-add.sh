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
	aname=${name}admin
	uname=${name}user
	apwd=4${name}apwd
	upwd=4${name}upwd
	dname=$(echo ${line} | cut -d ";" -f 2)
	rdname=${rootdir}/${dname}
	sdname=${sharedir}/${dname}
	# add accounts
	useradd -s /sbin/nologin ${aname} > /dev/null
	echo "${aname}:${apwd}" | chpasswd
	echo "User ${aname} added."
	useradd -g ${aname} -s /sbin/nologin ${uname} > /dev/null
	echo "${uname}:${upwd}" | chpasswd
	echo "User ${uname} added."
	printf "${apwd}\n${apwd}\n" | smbpasswd -a -s ${aname} > /dev/null
	echo "User ${aname} added to smbpasswd, and the passwd is ${apwd}."
	printf "${upwd}\n${upwd}\n" | smbpasswd -a -s ${uname} > /dev/null
	echo "User ${uname} added to smbpasswd, and the passwd is ${upwd}."
	# dirs
	cd ${rootdir}
	mkdir ${dname}
	echo "The directory ${rdname} created."
	chown ${aname}.${aname} ${dname}
	chmod 1770 ${dname}
	mkdir ${sdname}
	echo "The directory ${sdname} created."
	chown ${aname}.${aname} ${sdname}
	chmod 1775 ${sdname}
	# readme
	dreadme=${dname}/README.txt
	cp ${readme} ${dreadme}
	chown root.root ${dreadme}
	chmod 644 ${dreadme}
	# quota
	setquota -u ${aname} ${q10} ${q12} 0 0 /data
	setquota -u ${uname} ${q10} ${q12} 0 0 /data
	alladmin="${alladmin},@${aname}"
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
	echo "admin users = ${aname}" >> smb.conf
	echo "valid users = @${aname}" >> smb.conf
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
