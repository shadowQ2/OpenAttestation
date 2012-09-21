#!/bin/sh
RPM_BUILD_DIRECTORY=`pwd`
RPM_BUILD_SOURCE_DIRECTORY=`pwd`
RPM_BUILD_SPECS_DIRECTORY=`pwd`
RPM_BUILD_RPMS_DIRECTORY=`pwd`

./rpm_generate_src_tar.sh
rpmbuild -ba oat.spec
