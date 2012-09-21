%if %{defined fedora}
%define _TOMCAT "/usr/share/tomcat6"
%endif
%if %{defined suse_version}
%define _TOMCAT "/srv/tomcat"
%endif
%define __jar_repack 0

Name: oat
Summary: [OAT Crossbow] Host Integrity at Startup Installation of Appraiser Server
Version: 1.0.0 
Release: 2%{?dist}
License: DoD
Group: Department of Defense
Vendor: Department of Defense
Source: %{name}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}
BuildRequires: ant, trousers-devel
%if %{defined suse_version}
BuildRequires: java-1_7_0-openjdk-devel
%endif

%description
Host Integrity at Startup (OAT) is a project that explores how software and processes on standard desktop computers can be measured to detect and report important and specific changes which highlight potential compromise of the host platform. OAT provides the first examples of effective Measurement and Attestation on the path toward trusted platforms.

%package appraiser
Summary: The OAT Server
%if %{defined fedora}
Requires: httpd, tomcat6, mysql, mysql-server, php, php-mysql
%endif
%if %{defined suse_version}
Requires: apache2, tomcat, mysql, php5, php5-mysql, apache2-mod_php5, openssl
%endif

%description appraiser
Host Integrity at Startup (OAT) is a project that explores how software and processes on standard desktop computers can be measured to detect and report important and specific changes which highlight potential compromise of the host platform. OAT provides the first examples of effective Measurement and Attestation on the path toward trusted platforms.

%package client
Summary: The OAT Client
Version: 2.0
Release: 1%{?dist}

%description client
The NIARL_OAT_Standalone is a program by the National Information Assurance
Research Laboratory (NIARL) that uses Java and the NIARL_TPM_Module to
acquire integrity measurement data from a host's Trusted Platform Module
(TPM). The data is compiled
into an integrity report and sent to the OAT appraisal server. This package
does not automatically add the OAT Standalone startup script.

%clean
rm -rf $RPM_BUILD_ROOT

%prep
%setup -n %{name}

%build
# download and distribute the JAR_SOURCE to the source tree
pushd Source
sh download_jar_packages.sh
sh distribute_jar_packages.sh
sh build.sh
popd

%install
###################
#### appraiser ####
###################

# oat-appraiser dirs
mkdir -p $RPM_BUILD_ROOT/usr/share/oat-appraiser
mkdir -p $RPM_BUILD_ROOT/var/lib/oat-appraiser/CaCerts
mkdir $RPM_BUILD_ROOT/var/lib/oat-appraiser/ClientFiles
mkdir $RPM_BUILD_ROOT/var/lib/oat-appraiser/Certificate
mkdir -p $RPM_BUILD_ROOT%_sysconfdir/oat-appraiser/

# copy post install setup files
cp Installer/OAT-Appraiser-Configure/clientInstallRefresh.sh $RPM_BUILD_ROOT/usr/share/oat-appraiser
cp Installer/OAT-Appraiser-Configure/linuxClientInstallRefresh.sh $RPM_BUILD_ROOT/usr/share/oat-appraiser
cp Installer/OAT-Appraiser-Configure/oatSetup.txt $RPM_BUILD_ROOT/usr/share/oat-appraiser
cp Installer/OAT-Appraiser-Configure/OAT_Server_Install/oat_db.MySQL $RPM_BUILD_ROOT/usr/share/oat-appraiser
cp Installer/FilesForLinux/init.sql $RPM_BUILD_ROOT/usr/share/oat-appraiser
cp Installer/OAT_configure.sh $RPM_BUILD_ROOT/usr/share/oat-appraiser

# install configs
cp Installer/OAT-Appraiser-Configure/OAT_Server_Install/OAT.properties $RPM_BUILD_ROOT%_sysconfdir/oat-appraiser/ 

# tomcat install dir
mkdir -p $RPM_BUILD_ROOT/%_TOMCAT/webapps/

# install AttestationService
cp -R Source/AttestationService/WebContent $RPM_BUILD_ROOT/%_TOMCAT/webapps/AttestationService
cp Source/AttestationService/src/OpenAttestationWebServices.properties $RPM_BUILD_ROOT%_sysconfdir/oat-appraiser/


# install HisWebServices
cp -R Source/HisWebServices $RPM_BUILD_ROOT/%_TOMCAT/webapps/
cp Installer/OAT-Appraiser-Configure/OAT_Server_Install/hibernateOat.cfg.xml $RPM_BUILD_ROOT/%_TOMCAT/webapps/HisWebServices/WEB-INF/classes/
mv $RPM_BUILD_ROOT/%_TOMCAT/webapps/HisWebServices/WEB-INF/classes/OpenAttestation.properties $RPM_BUILD_ROOT%_sysconfdir/oat-appraiser/

# install HisPrivacyCAWebServices2
cp -R Source/HisPrivacyCAWebServices2 $RPM_BUILD_ROOT/%_TOMCAT/webapps/HisPrivacyCAWebServices2
mv $RPM_BUILD_ROOT/%_TOMCAT/webapps/HisPrivacyCAWebServices2/ClientFiles/lib $RPM_BUILD_ROOT/var/lib/oat-appraiser/ClientFiles/
mv $RPM_BUILD_ROOT/%_TOMCAT/webapps/HisPrivacyCAWebServices2/ClientFiles/TPMModule.properties $RPM_BUILD_ROOT/var/lib/oat-appraiser/ClientFiles/
rm -rf $RPM_BUILD_ROOT/%_TOMCAT/webapps/HisPrivacyCAWebServices2/ClientFiles/
rm -rf $RPM_BUILD_ROOT/%_TOMCAT/webapps/HisPrivacyCAWebServices2/CaCerts

#placing OAT web portal in correct folder to be seen by tomcat6
%if %{defined fedora}
mkdir -p $RPM_BUILD_ROOT/var/www/html/
cp -R Source/Portal $RPM_BUILD_ROOT/var/www/html/OAT
%endif
%if %{defined suse_version}
mkdir -p $RPM_BUILD_ROOT/srv/www/htdocs
cp -R Source/Portal $RPM_BUILD_ROOT/srv/www/htdocs/OAT
%endif

################
#### client ####
################
mkdir -p $RPM_BUILD_ROOT/usr/share/oat-client/lib
mkdir -p $RPM_BUILD_ROOT%_sysconfdir/init.d
cp -f Installer/FilesForLinux/OAT.sh $RPM_BUILD_ROOT%_sysconfdir/init.d/OAT.sh
cp Source/HisClient/OAT07.jpg Source/HisClient/log4j.properties $RPM_BUILD_ROOT/usr/share/oat-client/
cp Source/HisClient/jar/OAT_Standalone.jar $RPM_BUILD_ROOT/usr/share/oat-client/
cp -r Source/HisClient/lib $RPM_BUILD_ROOT/usr/share/oat-client/

%files appraiser
%config /etc/oat-appraiser/
%dir /var/lib/oat-appraiser/CaCerts
%dir /var/lib/oat-appraiser/Certificate
/var/lib/oat-appraiser/ClientFiles
/usr/share/oat-appraiser
%if %{defined fedora}
/var/www/html/OAT
%endif
%if %{defined suse_version}
/srv/www/htdocs/OAT
%endif

%if %{defined fedora}
/usr/share/tomcat6/webapps/AttestationService
/usr/share/tomcat6/webapps/HisWebServices
/usr/share/tomcat6/webapps/HisPrivacyCAWebServices2
%endif
%if %{defined suse_version}
/srv/tomcat/webapps/AttestationService
/srv/tomcat/webapps/HisWebServices
/srv/tomcat/webapps/HisPrivacyCAWebServices2
%endif


%post client
#TODO: chkconfig on the system script

%preun client
#TODO: stop the service before removing

%files client
%attr(755,-,-) /etc/init.d/OAT.sh
/usr/share/oat-client/OAT07.jpg
/usr/share/oat-client/OAT_Standalone.jar
/usr/share/oat-client/log4j.properties
/usr/share/oat-client/lib
