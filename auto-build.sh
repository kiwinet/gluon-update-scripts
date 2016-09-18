#!/bin/sh
##

. /opt/gluon-update-scripts/config.ini


cd $BASE_DIR/$BRANCH

git clone $REPO gluon -b $GLUON_RELISE
cd ./gluon
#mkdir ./site
git clone $SITE_REPO site -b v2016.1.6