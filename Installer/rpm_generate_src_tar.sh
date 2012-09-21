pushd ../
git archive --prefix=OAT-Appraiser-Base/ HEAD:Source > Installer/OAT-Appraiser-Base.tar
tar rf Installer/OAT-Appraiser-Base.tar JAR_SOURCE
gzip Installer/OAT-Appraiser-Base.tar
popd
