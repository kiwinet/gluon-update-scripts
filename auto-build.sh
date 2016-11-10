#!/bin/bash

##
## Config
##
MAIN_DIR="/opt/gluon-update-scripts-exp"
T="$(date +"%y-%m-%d.%H%M")"

##
## Body
##
NEW="0"
source $MAIN_DIR/config.sh

{

##
## Start Variables
##
if [ -z "$1" ]; then
	echo "Please select 's', 'b' or 'e'"
else
	if [ "$1" == "s" ]; then
		BRANCH=$BRANCH_S
		GLUON_SITE_RELEASE=$SITE_RELEASE_S
		NEW_RELEASE=$NEW_RELEASE_S
	elif [ "$1" == "b" ]; then
		BRANCH=$BRANCH_B
		GLUON_SITE_RELEASE=$SITE_RELEASE_B
		NEW_RELEASE=$NEW_RELEASE_B
		echo 'BETA not exist'
		exit 1
	elif [ "$1" == "e" ]; then
		BRANCH=$BRANCH_E
		GLUON_SITE_RELEASE=$SITE_RELEASE_E
		NEW_RELEASE=$NEW_RELEASE_E
	else
		echo "Please select 's', 'b' or 'e'"
		exit 1
	fi
	if [ -z "$2" ]; then
		DEBUG=''
	else 
		DEBUG=$2
	fi
fi

RELEASE_TAG="$NEW_RELEASE.${BRANCH:0:1}.$T"
MY_RELEASE="${NEW_RELEASE:1}-$BRANCH-$T"

cd $MAIN_DIR
if [ ! -d "$BASE_DIR" ]; then
	$MAIN_DIR/init_build.sh $BRANCH
	NEW="1"
fi

if [ ! -d "$BASE_DIR/$BRANCH" ]; then
	$MAIN_DIR/init_build.sh $BRANCH
	NEW="1"
fi

if [ ! -d "$BASE_DIR/$BRANCH/gluon" ]; then
	$MAIN_DIR/init_build.sh $BRANCH
	NEW="1"
fi

# Show summery
date

echo "New_REL: $NEW_RELEASE"
echo "R_TAG:   $RELEASE_TAG"
echo "G_REL:   $GLUON_RELEASE"
echo "My_REL:  $MY_RELEASE"

echo "Targets: $TARGETS"
echo "Futro ??? Targets: $TARGETSx86"
echo "Using $THREADS Cores"

##
## Exit kai to reikia
##
#exit 1

sleep 5 

cd $BASE_DIR/$BRANCH/gluon
if [ "$NEW" == '0' ]; then
	##
	## pull GLUON release
	##
	git checkout $GLUON_RELEASE
	git pull $REPO $GLUON_RELEASE

	/bin/rm -rf $BASE_DIR/$BRANCH/gluon/site
	##
	## clone Site config
	##
	git clone $SITE_REPO site -b $GLUON_SITE_RELEASE

	cd $BASE_DIR/$BRANCH/gluon/site
	git checkout $GLUON_SITE_RELEASE
fi
cd $BASE_DIR/$BRANCH/gluon

/bin/chown -R $USER:$USER $BASE_DIR
echo "> clean + update"
date

/bin/rm -rf $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/*
/bin/rm -rf $BASE_DIR/$BRANCH/gluon/output/images/factory/*
/bin/rm -rf $BASE_DIR/$BRANCH/gluon/output/modules/*

for TARGET in $TARGETS #$TARGETSx86
do
	#/usr/bin/sudo -u $USER 
	make clean GLUON_TARGET=$TARGET GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN -j $THREADS
done

#/usr/bin/sudo -u $USER 
make update GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN -j $THREADS

sleep 3

for TARGET in $TARGETS
do
	echo "> make $TARGET"
	date
	#/usr/bin/sudo -u $USER 
	make GLUON_TARGET=$TARGET GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN -j $THREADS $DEBUG
done

if [ -d "$BASE_DIR/$BRANCH/gluon/output/images" ]; then
	if [ -d "$BASE_DIR/$BRANCH/gluon/output/images/sysupgrade" ]; then
		cd $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade
		rm -f md5sums
		rm -f *.manifest
		md5sum * >> md5sums
	fi

	if [ -d "$BASE_DIR/$BRANCH/gluon/output/images/factory" ]; then
		cd $BASE_DIR/$BRANCH/gluon/output/images/factory
		rm -f md5sums
		rm -f *.manifest
		md5sum * >> md5sums
	fi

	echo "> make manifest"
	date
	cd $BASE_DIR/$BRANCH/gluon

	#/usr/bin/sudo -u $USER 
	make manifest GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN

	cd $MAIN_DIR

	#/usr/bin/sudo -u $USER 
	$MAIN_DIR/sign.sh $MAIN_DIR/secret $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/$BRANCH.manifest

	cd $BASE_DIR/$BRANCH/gluon

	if [ -a "$BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/$BRANCH.manifest" ]; then

		/bin/mkdir -p $HTML_IMAGES_DIR/../_archive/$BRANCH
		
		if [ -a "$HTML_IMAGES_DIR/../_archive/$BRANCH/images/sysupgrade/md5sums" ]; then
			/bin/more $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/md5sums >> $HTML_IMAGES_DIR/../_archive/$BRANCH/images/sysupgrade/md5sums
			/bin/rm -f $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/md5sums
		fi
		if [ -a "$HTML_IMAGES_DIR/../_archive/$BRANCH/images/factory/md5sums" ]; then
			/bin/more $HTML_IMAGES_DIR/$BRANCH/images/factory/md5sums >> $HTML_IMAGES_DIR/../_archive/$BRANCH/images/factory/md5sums
			/bin/rm -f $HTML_IMAGES_DIR/$BRANCH/images/factory/md5sums
		fi

		/bin/rm -f $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/$BRANCH.manifest
		/bin/cp -rf -t $HTML_IMAGES_DIR/../_archive/$BRANCH $HTML_IMAGES_DIR/$BRANCH/images
#		/bin/cp -rf -t $HTML_IMAGES_DIR/archive/$BRANCH $HTML_IMAGES_DIR/$BRANCH/modules

		/bin/rm -rf $HTML_IMAGES_DIR/$BRANCH/images

		/bin/mkdir -p $HTML_IMAGES_DIR/$BRANCH
		/bin/cp -rf -t $HTML_IMAGES_DIR/$BRANCH $BASE_DIR/$BRANCH/gluon/output/images
		/bin/cp -rf -t $HTML_IMAGES_DIR/$BRANCH $BASE_DIR/$BRANCH/gluon/output/modules
		/bin/cp -f $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/$BRANCH.manifest $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/$BRANCH-$T.manifest

		/usr/bin/curl -L http://siauliai.kiwinet.eu/firmware/$BRANCH/images/factory > $HTML_KIWI_DIR/$BRANCH/factory/index.html
		/usr/bin/curl -L http://siauliai.kiwinet.eu/firmware/$BRANCH/images/sysupgrade > $HTML_KIWI_DIR/$BRANCH/sysupgrade/index.html

		/bin/chown -R $USER:$USER $HTML_IMAGES_DIR
		/bin/chown -R $USER:$USER $HTML_KIWI_DIR
	fi

fi
} > >(tee -a /var/log/firmware-build/$MY_RELEASE.log) 2> >(tee -a /var/log/firmware-build/$MY_RELEASE.error.log | tee -a /var/log/firmware-build/$MY_RELEASE.log >&2)
