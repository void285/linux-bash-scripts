others="127.0.0.1 166.111.119.134"
myhost="helloiac.f3322.org"
ipadd=`ping -c 1 $myhost | grep "$myhost ("| sed "s/^PING $myhost (//g" | sed "s/).*$//g"`
echo -e "sshd : $others $ipadd" > /root/allowhosts
