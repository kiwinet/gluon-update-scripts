#!/bin/bash

##
## Main config
##

BRANCH_S="stable"
BRANCH_E="experimental"
BROKEN=true
NEW_RELEASE="v0.6"
GLUON_RELEASE="v2016.2.x"
GLUON_SITE_RELEASE="exp"
SITE="ksia"
USER="u1227"

# default wifi devices
TARGETS="ar71xx-generic"
#TARGETS="ar71xx-generic ar71xx-mikrotik ar71xx-nand mpc85xx-generic"

# raspberry devices
#TARGETS=$TARGETS" brcm2708-bcm2709 brcm2708-bcm2708 "

# vocore devices
#TARGETS=$TARGETS" ramips-mt7621 ramips-rt305x"

# bananapi devices
#TARGETS=$TARGETS" sunxi"

# x86 XEN, KVM
#TARGETS=$TARGETS" x86-xen_domu x86-kvm_guest"

# x86 generic
TARGETSx86="x86-generic x86-64"

THREADS="3"

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

