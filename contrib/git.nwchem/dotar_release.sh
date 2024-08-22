#!/usr/bin/env bash
Vx=7
Vy=2
Vz=3
NWVER="$Vx"."$Vy"."$Vz"-release
unset NWCHEM_TOP
export USE_MPI=y
TOPDIR=nwchem-"$Vx"."$Vy"."$Vz"
#BRANCH=release-"$Vx"-"$Vy"-"$Vz"
BRANCH=hotfix/release-7-2-0
#TOPDIR=nwchem
#BRANCH=master
# need to change BRANCH for patch releases
rm -rf temp.`date +%Y%m%d`
mkdir -p temp.`date +%Y%m%d`
cd temp.`date +%Y%m%d`
git clone --depth 1 --shallow-submodules -b $BRANCH https://github.com/nwchemgit/nwchem $TOPDIR
cd $TOPDIR/src/tools
rm -f *.tar.*
./get-tools-github
cd ../util
./util_ga_version.bash
./util_nwchem_version.bash
cd ..
# set USE_64TO32=y on by default since we do make 64_to_32 for this tarball
patch -p1  < ../contrib/git.nwchem/use6432y.patch
# do  make 64_to_32
export BLAS_SIZE=4
export USE_TBLITE=1
export NWCHEM_MODULES=all\ python\ gwmol\ xtb
make nwchem_config NWCHEM_MODULES=all\ python\ xtb
export EACCSD=1
export IPCCSD=1
export CCSDTQ=1
export MRCC_METHODS=1
make 64_to_32   USE_INTERNALBLAS=y
#rm `find . -name dependencies`
#rm `find . -name include_stamp`
#rm `find peigs -name peigs_stamp.*`
# cleanup on make nwchem_config output to address https://github.com/nwchemgit/nwchem/issues/178
rm -f config/nwchem_config.h config/NWCHEM_CONFIG stubs.F
rm -f *txt
cd ..
rm -rf bin lib
REVGIT="$(git describe --always)"
cd ..
echo 'revision ' $REVGIT
pwd
rm -f *md5 *tar*
echo 'generating tarballs '
tar --exclude=".git" -czf nwchem-"${NWVER}".revision-"${REVGIT}"-src.`date +%Y-%m-%d`.tar.gz $TOPDIR/*
echo 'tarball #1 done'
md5sum nwchem-"${NWVER}".revision-"${REVGIT}"-src.`date +%Y-%m-%d`.tar.gz > nwchem-"${NWVER}".revision"${REVGIT}"-src.`date +%Y-%m-%d`.tar.gz.md5
tar --exclude=".git" -cjf nwchem-"${NWVER}".revision-"${REVGIT}"-src.`date +%Y-%m-%d`.tar.bz2 $TOPDIR/*
echo 'tarball #2 done'
md5sum nwchem-"${NWVER}".revision-"${REVGIT}"-src.`date +%Y-%m-%d`.tar.bz2 >  nwchem-"${NWVER}".revision"${REVGIT}"-src.`date +%Y-%m-%d`.tar.bz2.md5
tar --exclude=".git" -cJf nwchem-"${NWVER}".revision-"${REVGIT}"-src.`date +%Y-%m-%d`.tar.xz $TOPDIR/*
echo 'tarball #3 done'
md5sum nwchem-"${NWVER}".revision-"${REVGIT}"-src.`date +%Y-%m-%d`.tar.xz >  nwchem-"${NWVER}".revision"${REVGIT}"-src.`date +%Y-%m-%d`.tar.xz.md5
tar --exclude=".git" -cjf nwchem-"${NWVER}".revision-"${REVGIT}"-srconly.`date +%Y-%m-%d`.tar.bz2 $TOPDIR/src/*
echo 'tarball #4 done'
md5sum nwchem-"${NWVER}".revision-"${REVGIT}"-srconly.`date +%Y-%m-%d`.tar.bz2>  nwchem-"${NWVER}".revision"${REVGIT}"-srconly.`date +%Y-%m-%d`.tar.bz2.md5
tar --exclude=".git" --exclude="src" -cjf nwchem-"${NWVER}".revision-"${REVGIT}"-nonsrconly.`date +%Y-%m-%d`.tar.bz2 $TOPDIR/*
echo 'tarball #5 done'
md5sum nwchem-"${NWVER}".revision-"${REVGIT}"-nonsrconly.`date +%Y-%m-%d`.tar.bz2 > nwchem-"${NWVER}".revision"${REVGIT}"-nonsrconly.`date +%Y-%m-%d`.tar.bz2.md5
ls -lrt
echo 'upload to http://192.101.105.206/'
