#!/bin/sh
RPM_BUILD_DIRECTORY=/root/rpmbuild
RPM_BUILD_SOURCE_DIRECTORY=/root/rpmbuild/SOURCES
RPM_BUILD_SPECS_DIRECTORY=/root/rpmbuild/SPECS
RPM_BUILD_RPMS_DIRECTORY=/root/rpmbuild/RPMS/x86_64
OATSOURCE_DIRECTORY=/root/OAT/Source
#TOMCAT_DIRECTORY=/root/OAT/Installer/apache-tomcat-7.0.26
EC_SIGNING_KEY_SIZE=2048
RPM_V=NIARL_OAT_Standalone-2.0-1.x86_64.rpm
SUCCESS_STATUS=1

ShowLogOK()
{
  echo -e "$1: --------------\033[32;49;5;1m [ OK ]\033[0m"
}

ShowLogFaild()
{
 SUCCESS_STATUS=0
 echo -e "$1:------------\033[31;49;5;1m [ Failed ]\033[0m"
 exit 0
}


CreateRPMdirectory()
{
  if test -d $RPM_BUILD_DIRECTORY;then
    rm -rf $RPM_BUILD_DIRECTORY
  fi
    mkdir $RPM_BUILD_DIRECTORY
    mkdir $RPM_BUILD_DIRECTORY/BUILD
    mkdir $RPM_BUILD_DIRECTORY/BUILDROOT
    mkdir $RPM_BUILD_DIRECTORY/RPMS
    mkdir $RPM_BUILD_DIRECTORY/SOURCES
    mkdir $RPM_BUILD_DIRECTORY/SPECS
    mkdir $RPM_BUILD_DIRECTORY/SRPMS
  ShowLogOK "creat RPM directory:"
}

#Install HIS-Appraiser-Base.tar.gz
TarOatAppraiserBase()
{
  if test -d ./OAT-Appraiser-Base;then
    rm OAT-Appraiser-Base.tar.gz
    tar -czvf OAT-Appraiser-Base.tar.gz ./OAT-Appraiser-Base/
  fi

  if test -e ./OAT-Appraiser-Base.tar.gz;then
    cp OAT-Appraiser-Base.tar.gz $RPM_BUILD_SOURCE_DIRECTORY
    ShowLogOK "./OAT-Appraiser-Base.tar.gz"
  else
    ShowLogFaild "./OAT-Appraiser-Base.tar.gz"
  fi
}


#NIARL_HIS_Standalone.tar.gz
CreatNiarlOatStandalone()
{
  if test -d NIARL_OAT_Standalone;then
   rm -rf  NIARL_OAT_Standalone
  fi
  mkdir NIARL_OAT_Standalone
 
  if test -e $OATSOURCE_DIRECTORY/HisClient/OAT07.jpg;then
    cp $OATSOURCE_DIRECTORY/HisClient/OAT07.jpg  NIARL_OAT_Standalone
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/HisClient/OAT07.jpg"
  fi

  if test -e ./FilesForLinux/OAT.sh;then
    cp ./FilesForLinux/OAT.sh  NIARL_OAT_Standalone
  else
    ShowLogFaild "./FilesForLinux/OAT.sh"
  fi
 if test -e $OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar;then
    cp $OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar NIARL_OAT_Standalone
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar"
  fi

  if test -e $OATSOURCE_DIRECTORY/HisClient/log4j.properties;then
    cp $OATSOURCE_DIRECTORY/HisClient/log4j.properties  NIARL_OAT_Standalone
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/HisClient/log4j.properties"
  fi

#  if test -e $OATSOURCE_DIRECTORY/HisClient/OAT.properties;then
#    cp $OATSOURCE_DIRECTORY/HisClient/OAT.properties  NIARL_OAT_Standalone
#  else
#    ShowLogFaild "$OATSOURCE_DIRECTORY/HisClient/OAT.properties"
#  fi

  if test -d  $OATSOURCE_DIRECTORY/HisClient/lib/;then
    cp -r  $OATSOURCE_DIRECTORY/HisClient/lib/ NIARL_OAT_Standalone
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/HisClient/lib/"
  fi


  tar -zcvf NIARL_OAT_Standalone.tar.gz  NIARL_OAT_Standalone
  mv NIARL_OAT_Standalone.tar.gz $RPM_BUILD_SOURCE_DIRECTORY
  rm -rf OAT
  mv NIARL_OAT_Standalone OAT
  tar -zcvf NIARL_OAT_Standalone.tar.gz OAT
  ShowLogOK "NIARL_OAT_Standalone.tar.gz"

  if test -e ./OAT-Standalone.spec;then
  cp -r ./OAT-Standalone.spec $RPM_BUILD_SPECS_DIRECTORY
  else
    ShowLogFaild "./OAT-Standalone.spec"
  fi

  rpmbuild -bb $RPM_BUILD_SPECS_DIRECTORY/OAT-Standalone.spec

  if test -e `$RPM_BUILD_DIRECTORY/RPMS/x86_64/$RPM_V`;then
    ShowLogOK "$RPM_V"
  else
    ShowLogFaild "$RPM_V"
  fi
}


LinuxOatInstall()
{
  if test -d linuxOatInstall;then
    rm -rf linuxOatInstall
  fi
  mkdir linuxOatInstall

  if test -e ./FilesForLinux/install.sh ;then
    cp ./FilesForLinux/install.sh linuxOatInstall
  else
    ShowLogFaild "./FilesForLinux/install.sh"
  fi

  if test -e ./FilesForLinux/general-install.sh;then
    cp ./FilesForLinux/general-install.sh linuxOatInstall
  else
    ShowLogFaild "./FilesForLinux/general-install.sh"
  fi

  if test -d ./FilesForLinux/shells;then
    cp -ar ./FilesForLinux/shells linuxOatInstall
  else
    ShowLogFaild "./FilesForLinux/shells"
  fi
  
  if test -e $RPM_BUILD_RPMS_DIRECTORY/$RPM_V;then
    cp $RPM_BUILD_RPMS_DIRECTORY/$RPM_V  linuxOatInstall
  else
    ShowLogFaild "$RPM_BUILD_RPMS_DIRECTORY/$RPM_V"
  fi

  if test -e $OATSOURCE_DIRECTORY/PrivacyCA/provisioner.sh;then
    cp $OATSOURCE_DIRECTORY/PrivacyCA/provisioner.sh linuxOatInstall
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/PrivacyCA/provisioner.sh"
  fi


  if test -e  $OATSOURCE_DIRECTORY/PrivacyCA/TPMModule.properties;then
    cp $OATSOURCE_DIRECTORY/PrivacyCA/TPMModule.properties linuxOatInstall
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/PrivacyCA/TPMModule.properties"
  fi


  if test -d $OATSOURCE_DIRECTORY/HisClient/lib;then
    cp -r $OATSOURCE_DIRECTORY/HisClient/lib  linuxOatInstall
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/HisClient/lib"
  fi 

  if test -d $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/ClientFiles/lib;then
    cp $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/ClientFiles/lib/* linuxOatInstall/lib
  else
  ShowLogFaild "$OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/ClientFiles/lib"
  fi

  if test -e linuxOatInstall/lib/PrivacyCA.jar;then
    rm -rf linuxOatInstall/lib/PrivacyCA.jar
  fi

  if test -e $OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar;then
    cp $OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar linuxOatInstall/lib
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar"
  fi
  chmod 755 linuxOatInstall/lib/*

  if test -e $OATSOURCE_DIRECTORY/TPMModule/plain/linux/NIARL_TPM_Module;then
    cp $OATSOURCE_DIRECTORY/TPMModule/plain/linux/NIARL_TPM_Module linuxOatInstall
    mkdir -p  linuxOatInstall/exe
    cp linuxOatInstall/NIARL_TPM_Module linuxOatInstall/exe
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/TPMModule/plain/linux/NIARL_TPM_Module"
  fi


  if test -e ./NIARL_OAT_Standalone.tar.gz;then
    cp ./NIARL_OAT_Standalone.tar.gz linuxOatInstall
  else
    ShowLogFaild "./NIARL_OAT_Standalone.tar.gz" 
  fi
  
  if test -e ./ClientInstallForLinux.zip;then
    rm -rf ClientInstallForLinux.zip
  fi
  zip -r ClientInstallForLinux.zip linuxOatInstall
  ShowLogOK "ClientInstallForLinux.zip"
  rm -rf linuxOatInstall
}

RePkgInstallOatAppraiserBase()
{
  CurDir=$(pwd)
  if test -e $RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base.tar.gz;then
     cd  $RPM_BUILD_SOURCE_DIRECTORY
     rm -rf OAT-Appraiser-Base
     tar -zxvf OAT-Appraiser-Base.tar.gz
  else
     ShowLogFaild "$RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base.tar.gz"
  fi
 
  
   if test -e $CurDir/FilesForLinux/apache-tomcat-6.0.29.tar.gz;then
     cp $CurDir/FilesForLinux/apache-tomcat-6.0.29.tar.gz $RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base
   else
     ShowLogFaild "$CurDir/FilesForLinux/apache-tomcat-6.0.29.tar.gz"
   fi
 
#  if test -e $CurDir/FilesForLinux/linuxClientInstallRefresh.zip;then 
#    cp $CurDir/FilesForLinux/linuxClientInstallRefresh.zip  $RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base
#  else
#    ShowLogFaild "$CurDir/FilesForLinux/linuxClientInstallRefresh.zip"
#  fi
  if test -e $CurDir/ClientInstallForLinux.zip;then
    cp $CurDir/ClientInstallForLinux.zip $RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base
  else
     ShowLogFaild "$CurDir/ClientInstallForLinux.zip"
  fi

  cd $RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base
  
  if test -e HisPrivacyCAWebServices2.war;then
    rm -rf HisPrivacyCAWebServices2.war
  fi

  if test -e $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war;then
    cp $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war .
  else
     ShowLogFaild "$OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war"
  fi

  mkdir HisPrivacyCAWebServices2
  mv HisPrivacyCAWebServices2.war HisPrivacyCAWebServices2
  cd HisPrivacyCAWebServices2
  unzip HisPrivacyCAWebServices2.war
  rm -rf HisPrivacyCAWebServices2.war

  echo "\n\r" >> setup.properties
  echo "ecSigningKeySize=$EC_SIGNING_KEY_SIZE" >> setup.properties
  echo "ecStorage=NVRAM" >> setup.properties
  mkdir -p /etc/oat-appraiser/
  mv setup.properties /etc/oat-appraiser/

  if test -d CaCerts;then
    rm -rf CaCerts
  fi
    mkdir CaCerts
  
  zip -9 -r HisPrivacyCAWebServices2.war .
  if test -e HisPrivacyCAWebServices2.war;then
    mv HisPrivacyCAWebServices2.war ../
    cd ../
    rm -rf HisPrivacyCAWebServices2
  fi

###HIS_Server_Install.zip####
 cd $RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base
 if test -e OAT_Server_Install.zip;then
   unzip OAT_Server_Install.zip
   rm -rf OAT_Server_Install.zip
 else 
   ShowLogFaild "OAT_Server_Install.zip"
 fi
 
 cd OAT_Server_Install
 
 if test -d HisWebServices;then
   rm -rf HisWebServices
 fi
 mkdir HisWebServices  

 if test -d $OATSOURCE_DIRECTORY/HisWebServices/WEB-INF;then
   cp -r $OATSOURCE_DIRECTORY/HisWebServices/WEB-INF ./HisWebServices/
 else
   ShowLogFaild "$OATSOURCE_DIRECTORY/HisWebServices/WEB-INF" 
 fi

# OpenAttestation *.war --> HIS_Server_Install.zip
#if test -e $CurDir/$OATSOURCE_DIRECTORY/OpenAttestationAdminConsole/OpenAttestationAdminConsole.war -a -e $CurDir/$OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war -e $CurDir/$OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war;then
    cp $OATSOURCE_DIRECTORY/OpenAttestationAdminConsole/OpenAttestationAdminConsole.war .
    cp $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war .
    cp $OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war .
#else
#    ShowLogFaild "$OATSOURCE_DIRECTORY/OpenAttestationAdminConsole/OpenAttestationAdminConsole.war ^ $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war ^ $OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war "  
#fi


if test -e $CurDir/FilesForLinux/init.sql;then
   cp $CurDir/FilesForLinux/init.sql .
else
   ShowLogFaild "$CurDir/FilesForLinux/init.sql"
fi

 cd $RPM_BUILD_SOURCE_DIRECTORY/OAT-Appraiser-Base

 zip -9 -r OAT_Server_Install.zip OAT_Server_Install

rm -rf OAT_Server_Install
######
#OAT.zip
if test -d $OATSOURCE_DIRECTORY/Portal;then
   cp -r $OATSOURCE_DIRECTORY/Portal OAT
else
   ShowLogFaild "$OATSOURCE_DIRECTORY/Portal"
fi

if test -e OAT.zip;then
  rm -rf OAT.zip
fi

zip -9 -r OAT.zip OAT
rm -rf OAT
#############

  cd $RPM_BUILD_SOURCE_DIRECTORY
  rm -rf OAT-Appraiser-Base.tar.gz
  tar -zcvf OAT-Appraiser-Base.tar.gz OAT-Appraiser-Base
  rm -rf OAT-Appraiser-Base
  cd $CurDir
  ShowLogOK "repackage OAT-Appraiser-Base.tar.gz"
}

RPMbuild()
{
  if test -e ./OAT-Appraiser-Base.spec;then
    cp OAT-Appraiser-Base.spec $RPM_BUILD_SPECS_DIRECTORY
  else
    ShowLogFaild "./OAT-Appraiser-Base.spec"
  fi
  
  if test -d /OAT-Appraiser-Base;then
  rm -rf /OAT-Appraiser-Base
  fi
  
  cd $RPM_BUILD_SPECS_DIRECTORY
  rpmbuild -bb OAT-Appraiser-Base.spec
}


Build_xml()
{
  CurDir=$(pwd)
  if test -e $OATSOURCE_DIRECTORY/HisAppraiser/HisAppraiser.jar;then
  rm -rf $OATSOURCE_DIRECTORY/HisAppraiser/HisAppraiser.jar
  fi
  
  if test -e $OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar;then
    rm -rf $OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar
  fi
  
  if test -e $OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar;then
    rm -rf $OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar
  fi
  
  if test -e $OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war;then
    rm -rf $OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war
  fi
  
  if test -e $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war;then
    rm -rf $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war
  fi
  
  if test -e $OATSOURCE_DIRECTORY/HisWebServices/clientlib/HisWebServices-client.jar;then
    rm -rf $OATSOURCE_DIRECTORY/HisWebServices/clientlib/HisWebServices-client.jar
  fi

 if test -e $OATSOURCE_DIRECTORY/HisWebServices/HisWebServices.war;then
    rm -rf $OATSOURCE_DIRECTORY/HisWebServices/HisWebServices.war
  fi 
 
  if test -e $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war;then
    rm -rf $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war
  fi

  if test -e $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/clientlib/HisPrivacyCAWebServices2-client.jar;then
    rm -rf $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/clientlib/HisPrivacyCAWebServices2-client.jar
  fi
  
  if test -e $OATSOURCE_DIRECTORY/OpenAttestationAdminConsole/OpenAttestationAdminConsole.war;then
    rm -rf  $OATSOURCE_DIRECTORY/OpenAttestationAdminConsole/OpenAttestationAdminConsole.war
  fi 
 
  if test -e $OATSOURCE_DIRECTORY/build.sh;then
    cd $OATSOURCE_DIRECTORY
#    sh build.sh $TOMCAT_DIRECTORY
    sh build.sh
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/build.sh"
  fi

  
  if test -d $OATSOURCE_DIRECTORY/OpenAttestationAdminConsole;then
    cd $OATSOURCE_DIRECTORY/OpenAttestationAdminConsole
    ant -file build.xml
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/OpenAttestationAdminConsole"
  fi


  if test -d $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices;then
    cd $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices
    ant -file build.xml
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices"
  fi
 
  if test -d $OATSOURCE_DIRECTORY/OpenAttestationWebServices;then
    cd $OATSOURCE_DIRECTORY/OpenAttestationWebServices
    cp -rf  $OATSOURCE_DIRECTORY/HisAppraiser/HisAppraiser.jar ./WebContent/WEB-INF/lib/
    ant -file build.xml
  else
    ShowLogFaild "$OATSOURCE_DIRECTORY/OpenAttestationWebServices"
  fi

  if test -e $OATSOURCE_DIRECTORY/HisAppraiser/HisAppraiser.jar;then
    ShowLogOK $OATSOURCE_DIRECTORY/HisAppraiser/HisAppraiser.jar
  else
   ShowLogFaild $OATSOURCE_DIRECTORY/HisAppraiser/HisAppraiser.jar
  fi
  
  if test -e $OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar;then
    ShowLogOK $OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar
  else
    ShowLogFaild $OATSOURCE_DIRECTORY/PrivacyCA/PrivacyCA.jar
  fi

  if test -e $OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar;then
    ShowLogOK $OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar
  else
    ShowLogFaild $OATSOURCE_DIRECTORY/HisClient/jar/OAT_Standalone.jar
  fi
  
  if test -e $OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war;then
    ShowLogOK $OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war
  else
    ShowLogFaild $OATSOURCE_DIRECTORY/OpenAttestationWebServices/OpenAttestationWebServices.war
  fi
  
  if test -e $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war;then
    ShowLogOK $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war
  else
    ShowLogFaild $OATSOURCE_DIRECTORY/OpenAttestationManifestWebServices/OpenAttestationManifestWebServices.war
  fi
  
  if test -e $OATSOURCE_DIRECTORY/HisWebServices/HisWebServices.war;then
    ShowLogOK $OATSOURCE_DIRECTORY/HisWebServices/HisWebServices.war
  else
    ShowLogFaild $OATSOURCE_DIRECTORY/HisWebServices/HisWebServices.war
  fi
 
  if test -e $OATSOURCE_DIRECTORY/HisWebServices/clientlib/HisWebServices-client.jar;then
    ShowLogOK $OATSOURCE_DIRECTORY/HisWebServices/clientlib/HisWebServices-client.jar
  else
    ShowLogFaild  $OATSOURCE_DIRECTORY/HisWebServices/clientlib/HisWebServices-client.jar
  fi
 
 
  if test -e $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war;then
    ShowLogOK $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war
  else
    ShowLogFaild $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/HisPrivacyCAWebServices2.war
  fi

  if test -e $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/clientlib/HisPrivacyCAWebServices2-client.jar;then
    ShowLogOK $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/clientlib/HisPrivacyCAWebServices2-client.jar
  else
    ShowLogFaild  $OATSOURCE_DIRECTORY/HisPrivacyCAWebServices2/clientlib/HisPrivacyCAWebServices2-client.jar
  fi


  cd $CurDir
}

#main
SourceFileOP=-s
#TomCatOP=-t
if [ $# -lt 2 ];then 
ShowLogFaild "Parameter ERROR! for example:sh rpm.sh -s /usr/local/src/OAT/Source"
fi

if [ $1 = $SourceFileOP ];then
  OATSOURCE_DIRECTORY=$2
fi

if [ -d $OATSOURCE_DIRECTORY ]; then
  ShowLogOK "Source file"
else
  ShowLogFaild "$OATSOURCE_DIRECTORY  No such directory"
fi

#if [ $3 = $TomCatOP ];then
#  TOMCAT_DIRECTORY=$4
#fi

#if [ -d $TOMCAT_DIRECTORY ]; then
#  ShowLogOK "tomcat"
#else
#  ShowLogFaild "$TOMCAT_DIRECTORY  No such directory"
#fi

if [ $# -gt 3 -a $3 = "-ks" ];then
  EC_SIGNING_KEY_SIZE=$4
fi
echo "EC_SIGNING_KEY_SIZE=$4"


Build_xml
CreateRPMdirectory
TarOatAppraiserBase
CreatNiarlOatStandalone
LinuxOatInstall
RePkgInstallOatAppraiserBase
RPMbuild
echo $SUCCESS_STATUS
if [ $SUCCESS_STATUS -eq 1 ];then
  ShowLogOK "RPM build"
else
  ShowLogFaild "RPM build"
fi
