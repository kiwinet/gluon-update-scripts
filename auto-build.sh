#!/bin/bash

##
## Config
##
SCRIPT=$(readlink -f "$0")
MAIN_DIR=`dirname "$SCRIPT"`
export PATH=$PATH:$MAIN_DIR
export FORCE_UNSAFE_CONFIGURE=1

T="$(date +"%y-%m-%d.%H%M")"

##
## Body
##
NEW="0"
source $MAIN_DIR/config.sh



##
## Start Variables
##
if [ -z "$1" ]; then
	echo "Please select 's', 'b' or 'e'"
	exit 1
else
	if [ "$1" == "s" ]; then
		BRANCH=$BRANCH_S
		GLUON_SITE_RELEASE=$SITE_RELEASE_S
		GLUON_SITE_BRANCH=$SITE_BRANCH_S
		NEW_RELEASE=$NEW_RELEASE_S
		TARGETS=$TARGETS_S
		GLUON_RELEASE=$GLUON_RELEASE_S
		GLUON_BRANCH=$GLUON_BRANCH_S
		BROKEN=$BROKEN_S
	elif [ "$1" == "b" ]; then
		BRANCH=$BRANCH_B
		GLUON_SITE_RELEASE=$SITE_RELEASE_B
		GLUON_SITE_BRANCH=$SITE_BRANCH_B
		NEW_RELEASE=$NEW_RELEASE_B
		TARGETS=$TARGETS_B
		GLUON_RELEASE=$GLUON_RELEASE_B
		GLUON_BRANCH=$GLUON_BRANCH_B
		BROKEN=$BROKEN_B
		#echo 'BETA not exist'
		#exit 1
	elif [ "$1" == "e" ]; then
		BRANCH=$BRANCH_E
		GLUON_SITE_RELEASE=$SITE_RELEASE_E
		GLUON_SITE_BRANCH=$SITE_BRANCH_E
		NEW_RELEASE=$NEW_RELEASE_E
		TARGETS=$TARGETS_E
		GLUON_RELEASE=$GLUON_RELEASE_E
		GLUON_BRANCH=$GLUON_BRANCH_E
		BROKEN=$BROKEN_E
	else
		echo "Please select 's', 'b' or 'e'"
		exit 1
	fi
	if [ -z "$2" ]; then
		DEBUG=''
	else
		DEBUG='V=s'
	fi
fi

RELEASE_TAG="$NEW_RELEASE.${BRANCH:0:1}.$T"
MY_RELEASE="${NEW_RELEASE:1}-$BRANCH-$T"

{
echo " "

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

echo "FIRST TIME:  $NEW"

##
## Exit kai to reikia
##
#exit 1

sleep 5

if [ "$NEW" == '0' ]; then
	cd $BASE_DIR/$BRANCH/gluon
	##
	## pull GLUON release
	##
	git fetch
	git pull $REPO $GLUON_BRANCH
	git checkout tags/$GLUON_RELEASE

	/bin/rm -rf $BASE_DIR/$BRANCH/gluon/site
	##
	## clone Site config
	##
	git clone $SITE_REPO site -b $GLUON_SITE_BRANCH

	cd $BASE_DIR/$BRANCH/gluon/site
	git fetch
	git checkout tags/$GLUON_SITE_RELEASE
fi
cd $BASE_DIR/$BRANCH/gluon

/bin/chown -R $USER:$USER $BASE_DIR
echo "> clean + update"
date

/bin/rm -rf $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/*
/bin/rm -rf $BASE_DIR/$BRANCH/gluon/output/images/factory/*
/bin/rm -rf $BASE_DIR/$BRANCH/gluon/output/modules/*
if [ -z "$3" ]; then
	if [ "$NEW" == '0' ]; then
		for TARGET in $TARGETS #$TARGETSx86
		do
			echo "> make clean $TARGET"
			#/usr/bin/sudo -u $USER
			make clean GLUON_TARGET=$TARGET GLUON_AUTOUPDATER_BRANCH=$BRANCH GLUON_AUTOUPDATER_ENABLED=1 GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN -j $THREADS
		done
	fi
fi

echo "> make update"
#/usr/bin/sudo -u $USER
make update GLUON_AUTOUPDATER_BRANCH=$BRANCH GLUON_AUTOUPDATER_ENABLED=1 GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN -j $THREADS

sleep 3

for TARGET in $TARGETS
do
	echo "> make $TARGET"
	date
	#/usr/bin/sudo -u $USER
	make GLUON_TARGET=$TARGET GLUON_AUTOUPDATER_BRANCH=$BRANCH GLUON_AUTOUPDATER_ENABLED=1 GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN -j $THREADS $DEBUG
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
	make manifest GLUON_AUTOUPDATER_BRANCH=$BRANCH GLUON_AUTOUPDATER_ENABLED=1 GLUON_RELEASE=$MY_RELEASE BROKEN=$BROKEN

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
