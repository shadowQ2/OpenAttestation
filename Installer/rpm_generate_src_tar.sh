pushd ../
git archive --prefix=oat/ HEAD: > Installer/oat.tar
popd
rm -rf oat
ln -s ../ oat
tar rhf oat.tar oat/JAR_SOURCE
gzip oat.tar
