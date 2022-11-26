#!/bin/bash

##
## Main config
##

SITE="ksia"
USER="u1227"
BRANCH_S="stable"
BRANCH_B="beta"
BRANCH_E="experimental"
BROKEN_S=false
BROKEN_B=false
BROKEN_E=false

NEW_RELEASE_S="v0.6"
NEW_RELEASE_B="v0.6.7"
NEW_RELEASE_E="v0.9.2"

GLUON_RELEASE_S="v2016.2.1"
GLUON_RELEASE_B="v2016.2.7"
GLUON_RELEASE_E="v2021.1.1"

GLUON_BRANCH_S="v2016.2.x"
GLUON_BRANCH_B="v2016.2.x"
GLUON_BRANCH_E="v2021.1.x"

SITE_BRANCH_S="stable"
SITE_BRANCH_B="beta"
SITE_BRANCH_E="master"

SITE_RELEASE_S=$NEW_RELEASE_S
SITE_RELEASE_B=$NEW_RELEASE_B"-beta"
SITE_RELEASE_E=$NEW_RELEASE_E"-master"

# default wifi devices
TARGETS_S="ar71xx-generic ar71xx-mikrotik ar71xx-nand mpc85xx-generic"
TARGETS_B="ar71xx-generic"
# TARGETS_E="ath79-generic"
#TARGETS_E="ath79-generic ramips-mt7620 ramips-mt7621 ramips-mt76x8 mpc85xx-p1010"
#TARGETS_E="ar71xx-generic ar71xx-mikrotik ar71xx-nand"
TARGETS_E="ar71xx-generic ar71xx-tiny ramips-mt76x8"
# mpc85xx-generic ramips-mt7620 ramips-mt76x8"

# raspberry devices
#TARGETS=$TARGETS" brcm2708-bcm2709 brcm2708-bcm2708 "

# vocore devices
#TARGETS=$TARGETS" ramips-mt7621 ramips-rt305x"

# bananapi devices
#TARGETS=$TARGETS" sunxi"

# x86 XEN, KVM
#TARGETS=$TARGETS" x86-xen_domu x86-kvm_guest"

# x86 generic
#TARGETSx86="x86-generic x86-64"
TARGETSx86=""

THREADS="4"

##
##
## REPO
##

REPO="https://github.com/freifunk-gluon/gluon.git"
SITE_REPO="https://github.com/kiwinet/site-$SITE.git"

##
## DIR config
##

BASE_DIR="/opt/gluon-update"
HTML_IMAGES_DIR="/home/u1227/web/siauliai.kiwinet.eu/public_html/firmware"
HTML_KIWI_DIR="/home/u1227/web/kiwinet.eu/public_html/firmware"

