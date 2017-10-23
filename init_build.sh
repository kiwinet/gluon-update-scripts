#!/bin/bash
##
##
##
## Config
##
SCRIPT=$(readlink -f "$0")
MAIN_DIR=`dirname "$SCRIPT"`
export PATH=$PATH:$MAIN_DIR

##
## Body
##
source $MAIN_DIR/config.sh


source /opt/gluon-update-scripts/config.sh

if [ -z "$1" ]; then
	echo 'stable, beta or experimental 1'
	exit 1
fi

if [ "$1" == "stable" ]; then
	BRANCH=$BRANCH_S
	GLUON_SITE_RELEASE=$SITE_RELEASE_S
	GLUON_SITE_BRANCH=$SITE_BRANCH_S
	NEW_RELEASE=$NEW_RELEASE_S
	TARGETS=$TARGETS_S
	GLUON_RELEASE=$GLUON_RELEASE_S
	BROKEN=$BROKEN_S
elif [ "$1" == "beta" ]; then
	BRANCH=$BRANCH_B
	GLUON_SITE_RELEASE=$SITE_RELEASE_B
	GLUON_SITE_BRANCH=$SITE_BRANCH_B
	NEW_RELEASE=$NEW_RELEASE_B
	TARGETS=$TARGETS_B
	GLUON_RELEASE=$GLUON_RELEASE_B
	BROKEN=$BROKEN_B
	#echo 'BETA not exist'
	#exit 1
elif [ "$1" == "experimental" ]; then
	BRANCH=$BRANCH_E
	GLUON_SITE_RELEASE=$SITE_RELEASE_E
	GLUON_SITE_BRANCH=$SITE_BRANCH_E
	NEW_RELEASE=$NEW_RELEASE_E
	TARGETS=$TARGETS_E
	GLUON_RELEASE=$GLUON_RELEASE_E
	BROKEN=$BROKEN_E
else
	echo 'stable, beta or experimental 1'
	exit 1
fi

RELEASE_TAG="$NEW_RELEASE.${BRANCH:0:1}.$T"
MY_RELEASE="${NEW_RELEASE:1}-$BRANCH-$T"

if [ ! -d "$BASE_DIR" ]; then
	/bin/mkdir -p $BASE_DIR
fi

if [ ! -d "$BASE_DIR/$1" ]; then
	/bin/mkdir -p $BASE_DIR/$1
fi

cd $BASE_DIR/$1
##
## clone GLUON
##
git clone $REPO gluon -b $GLUON_RELEASE

cd $BASE_DIR/$1/gluon
git checkout $GLUON_RELEASE

/bin/rm -rf $BASE_DIR/$1/gluon/site
##
## clone SITE config
##
git clone $SITE_REPO site -b $GLUON_SITE_BRANCH

cd $BASE_DIR/$1/gluon/site
git checkout tags/$GLUON_SITE_RELEASE -b $GLUON_SITE_BRANCH
