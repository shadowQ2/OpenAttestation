#!/bin/bash
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Making OAT Appraiser"



#######Install script###########################################################

tomcat="/usr/share/tomcat6/"
###Random generation /dev/urandom is good but just in case...
# Creating randoms for the p12 files and setting up truststore and keystore
ip12="internal.p12"
ipassfile="internal.pass"
idomfile="internal.domain"
iloc="/usr/share/oat-appraiser/"
p12file="$loc$ip12"
RAND1=$(dd if=/dev/urandom bs=1 count=1024)
RAND2=$(dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}')
RAND3=$(dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}')
randbits="$(echo "$( echo "`clock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass="${randbits:0:30}"
randbits2="$(echo "$( echo "`clock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass2="${randbits2:0:30}"
randbits3="$(echo "$( echo "`clock`" | md5sum | md5sum )$( echo "`dd if=/dev/urandom bs=1 count=1024`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum)$(echo "`dd if=/dev/urandom bs=1 count=1024 | awk '{print $1}'`" | md5sum | md5sum)$(echo "`clock`" | md5sum | md5sum )" | md5sum | md5sum )"
randpass3="${randbits3:0:30}"
p12pass="$randpass"
mysqlPass="$randpass2"
keystore="keystore.jks"
truststore="TrustStore.jks"
if [ "`ls $iloc | grep $ip12`" ] && [ "`ls $iloc | grep $ipassfile`" ] ; then
  p12pass="`cat $loc$ipassfile`"
fi
if [ "`ls $iloc | grep $idomfile`" ] ; then
  domain="`cat $loc$idomfile`"
fi


service tomcat6 stop 

#chkconfig --del NetworkManager
chkconfig network on
chkconfig httpd on
chkconfig mysqld on
service httpd start
service mysqld start

#Sets up database and user
ISSKIPGRANTEXIT=`grep skip-grant-tables /etc/my.cnf`
if [ ! "$ISSKIPGRANTEXIT" ]; then
  sed -i 's/\[mysqld\]/\[mysqld\]\nskip-grant-tables/g' /etc/my.cnf
fi

mysql -u root --execute="CREATE DATABASE oat_db; FLUSH PRIVILEGES; GRANT ALL ON oat_db.* TO 'oatAppraiser'@'localhost' IDENTIFIED BY '$randpass3';"


mysql -u root --execute="DROP DATABASE IF EXISTS oat_db;"
mysql -u root < /usr/share/oat-appraiser/oat_db.MySQL
mysql -u root < /usr/share/oat-appraiser/init.sql
#setting up access control in tomcat context.xml
sed -i "/<\/Context>/i\\   <Resource name=\"jdbc\/oat\" auth=\"Container\" type=\"javax.sql.DataSource\"\n    username=\"oatAppraiser\" password=\"$randpass3\" driverClassName=\"com.mysql.jdbc.Driver\"\n    url=\"jdbc:mysql:\/\/localhost:3306\/oat_db\"\/>" $tomcat/conf/context.xml

#setting up port 8443 in tomcat server.xml
sed -i "s/ <\/Service>/<Connector port=\"8443\" minSpareThreads=\"5\" maxSpareThreads=\"75\" enableLookups=\"false\" disableUploadTimeout=\"true\" acceptCount=\"100\" maxThreads=\"200\" scheme=\"https\" secure=\"true\" SSLEnabled=\"true\" clientAuth=\"want\" sslProtocol=\"TLS\" ciphers=\"TLS_ECDH_anon_WITH_AES_256_CBC_SHA, TLS_ECDH_anon_WITH_AES_128_CBC_SHA, TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA, TLS_ECDH_RSA_WITH_AES_256_CBC_SHA, TLS_ECDH_RSA_WITH_AES_128_CBC_SHA, TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA, TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA, TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA, TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA, TLS_DHE_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_DSS_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_DHE_RSA_WITH_AES_128_CBC_SHA, TLS_DHE_DSS_WITH_AES_128_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA\" keystoreFile=\"\/var\/lib\/oat-appraiser\/Certificate\/keystore.jks\" keystorePass=\"$p12pass\" truststoreFile=\"\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks\" truststorePass=\"password\" \/><\/Service>/g" $tomcat/conf/server.xml




 echo "$tomcat/webapps/OpenAttestationAdminConsole/WEB-INF/classes/manifest.properties has updated"
 sed -i "s/<server.domain>/$(hostname)/g" /etc/oat-appraiser/OpenAttestationAdminConsole.properties
 sed -i "s/<server.domain>/$(hostname)/g" /etc/oat-appraiser/manifest.properties
#configuring hibernateHis for OAT appraiser setup
sed -i 's/<property name="connection.username">root<\/property>/<property name="connection.username">oatAppraiser<\/property>/' $tomcat/webapps/HisWebServices/WEB-INF/classes/hibernateOat.cfg.xml
sed -i "s/<property name=\"connection.password\">oat-password<\/property>/<property name=\"connection.password\">$randpass3<\/property>/" $tomcat/webapps/HisWebServices/WEB-INF/classes/hibernateOat.cfg.xml
sed -i "s/<server.domain>/$(hostname)/g" /etc/oat-appraiser/OpenAttestation.properties
sed -i "s/^TrustStore.*$/TrustStore=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g" /etc/oat-appraiser/OpenAttestationAdminConsole.properties

sed -i "s/^truststore_path.*$/truststore_path=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g" /etc/oat-appraiser/manifest.properties
sed -i "s/^truststore_path.*$/truststore_path=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g" /etc/oat-appraiser/OpenAttestation.properties

sed -i "s/^TrustStore.*$/TrustStore=\/var\/lib\/oat-appraiser\/Certificate\/TrustStore.jks/g"  /etc/oat-appraiser/OpenAttestation.properties

#setting all files in the OAT portal to be compiant to selinux
# this should be done by the rpm
#/sbin/restorecon -R '/var/www/html/OAT'

#setting the user and password in the OAT appraiser that will be used to access the mysql database.
sed -i 's/user = "root"/user = "oatAppraiser"/g' /var/www/html/OAT/includes/dbconnect.php
sed -i "s/pass = \"newpwd\"/pass = \"$randpass3\"/g" /var/www/html/OAT/includes/dbconnect.php

#setting up OAT database to talk with the web portal correctly
mysql -u root --database=oat_db < /usr/share/oat-appraiser/oatSetup.txt


#this code sets up the certificate attached to this computers hostname
cd /var/lib/oat-appraiser/Certificate/
echo "127.0.0.1       `hostname`" >> /etc/hosts
if [ "`echo $p12pass | grep $randpass`" ] ; then
  openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout hostname.pem -out hostname.cer -subj "/C=US/O=U.S. Government/OU=DoD/CN=`hostname`"
  openssl pkcs12 -export -in hostname.cer -inkey hostname.pem -out $p12file -passout pass:$p12pass
fi

keytool -importkeystore -srckeystore $p12file -destkeystore $keystore -srcstoretype pkcs12 -srcstorepass $p12pass -deststoretype jks -deststorepass $p12pass -noprompt

myalias=`keytool -list -v -keystore $keystore -storepass $p12pass | grep -B2 'PrivateKeyEntry' | grep 'Alias name:'`

keytool -changealias -alias ${myalias#*:} -destalias tomcat -v -keystore $keystore -storepass $p12pass

rm -f $truststore
keytool -import -keystore $truststore -storepass password -file hostname.cer -noprompt

service tomcat6 start

sed -i "s/\/usr\/lib\/apache-tomcat-6.0.29/%_TOMCAT_DIR_COFNIG_TYPE\/%_TOMCAT_NAME/g" clientInstallRefresh.sh
sed -i "s/\/usr\/lib\/apache-tomcat-6.0.29/%_TOMCAT_DIR_COFNIG_TYPE\/%_TOMCAT_NAME/g" linuxClientInstallRefresh.sh

cd $cur_dir

sleep 5

#zky: for linux, do similar things

mkdir /usr/share/oat-appraiser/ClientInstallForLinux

cp -r -f /%{name}/linuxOatInstall /%{name}/ClientInstallForLinux

cp -r -f /var/lib/oat-appraiser/ClientFiles/PrivacyCA.cer /usr/share/oat-appraiser/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/TrustStore.jks /usr/share/oat-appraise/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/OATprovisioner.properties /usr/share/oat-appraiser/ClientInstallForLinux/
cp -r -f /var/lib/oat-appraiser/ClientFiles/OAT.properties /usr/share/oat-appraiser/ClientInstallForLinux/
sed -i '/ClientPath/s/C:.*/\/OAT/' /usr/share/oat-appraiser/ClientInstallForLinux/OATprovisioner.properties
sed -i 's/NIARL_TPM_Module\.exe/NIARL_TPM_Module/g' /usr/share/oat-appraiser/ClientInstallForLinux/OAT.properties
sed -i 's/HIS07\.jpg/OAT07\.jpg/g' /usr/share/oat-appraiser/ClientInstallForLinux/OAT.properties
cd /usr/share/oat-appraiser/
zip -9 -r /var/www/html/ClientInstallForLinux.zip ClientInstallForLinux


#creates the web page that allows access for the download of the client files folder
cat << 'EOF' > /var/www/html/ClientInstaller.html
<html>
<body>
<h1><a href="ClientInstallForLinux.zip">Client Installation Files For Linux</a></h1>
</body>
</html>
EOF


#chmod 755 /var/www/html/Client*


#closes some known security holes in tomcat6
sed -i "s/AllowOverride None/AllowOverride All/" /etc/httpd/conf/httpd.conf
echo "TraceEnable Off" >> /etc/httpd/conf/httpd.conf
sed -i "s/ServerTokens OS/ServerTokens Prod/" /etc/httpd/conf/httpd.conf
sed -i "s/Options Indexes/Options/" /etc/httpd/conf/httpd.conf
sed -i "s/expose_php = On/expose_php = Off/" /etc/php.ini

echo "" > /etc/httpd/conf.d/welcome.conf

/sbin/restorecon -R '/var/www/html/OAT'


#######################################################################
printf "done\n"
