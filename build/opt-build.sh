#! /bin/bash

set -xe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

if [ "$#" -lt "1" ] ; then
  echo "Please provide an installation path such as /opt/ICGC"
  exit 1
fi

# get path to this script
SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

# get the location to install to
INST_PATH=$1
mkdir -p $1
INST_PATH=`(cd $1 && pwd)`
echo $INST_PATH

# get current directory
INIT_DIR=`pwd`

CPU=`grep -c ^processor /proc/cpuinfo`
if [ $? -eq 0 ]; then
  if [ "$CPU" -gt "6" ]; then
    CPU=6
  fi
else
  CPU=1
fi
echo "Max compilation CPUs set to $CPU"

SETUP_DIR=$INIT_DIR/install_tmp
mkdir -p $SETUP_DIR/distro # don't delete the actual distro directory until the very end
mkdir -p $INST_PATH/bin
cd $SETUP_DIR

# make sure tools installed can see the install loc of libraries
set +u
export LD_LIBRARY_PATH=`echo $INST_PATH/lib:$LD_LIBRARY_PATH | perl -pe 's/:\$//;'`
export LIBRARY_PATH=`echo $INST_PATH/lib:$LIBRARY_PATH | perl -pe 's/:\$//;'`
export C_INCLUDE_PATH=`echo $INST_PATH/include:$C_INCLUDE_PATH | perl -pe 's/:\$//;'`
export PATH=`echo $INST_PATH/bin:$PATH | perl -pe 's/:\$//;'`
export MANPATH=`echo $INST_PATH/man:$INST_PATH/share/man:$MANPATH | perl -pe 's/:\$//;'`
export PERL5LIB=`echo $INST_PATH/lib/perl5:$PERL5LIB | perl -pe 's/:\$//;'`
set -u

# .net
if [ ! -e $SETUP_DIR/dotnet.success ]; then
    curl -sSL --retry 10 -o ${INST_PATH}/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/${VER_UBUNTU}/packages-microsoft-prod.deb
    touch $SETUP_DIR/dotnet.success
fi

# PISCES
if [ ! -e $SETUP_DIR/pisces.success ]; then
    curl -sSL --retry 10 -o package.tar.gz https://github.com/Illumina/Pisces/releases/download/v5.2.10.49/Pisces_${VER_PISCES}.tar.gz
    mkdir $INST_PATH/Pisces
    tar --strip-components 1 -C $INST_PATH/Pisces -xzf package.tar.gz
    rm package.tar.gz
    ln -s $INST_PATH/Pisces/*.dll $INST_PATH/bin
    touch $SETUP_DIR/pisces.success
fi

