#!/usr/bin/env bash
# MIT License
#
# Copyright (c) 2019 Collin Pasternack
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# CPasternack github.com/cpasternack
# 09/02/2019
# Install smartmon tools in opensolaris/illumos
# v0.1
# Instructions on setting up smf originally from: 
# https://nlfiedler.github.io/2009/02/22/setting-up-smartmontools-on-opensolaris.html
#
SMARTMONTOOLSDIR=/etc/smartmontools
SMARTDXML=/var/svc/manifest/site/smartd.xml
SMARTDLXML=smartd.xml
SMARTMT=smartmontools
SMARTDCONF=smartd.conf
SMARTDINITD=smartd.init
USERID=`id -u`

# must run with enhanced permissions
if [[ 0 -ne $USER ]]
then
	echo "This script must be run with /usr/bin/pfexec or /usr/bin/pfbash"
	exit 1
fi

# check that smartmontools directory in /etc exists
if [ ! -d ${SMARTMONTOOLSDIR} ]
then
	mkdir -p /etc/smartmontools
fi

# copy the file if it exists and is not empty
if [ -e ${SMARTDLXML} ] && [ -s ${SMARTDLXML} ]
then
	cp ./$SMARTDLXML $SMARTDXML
	cp ./smartd.conf /etc/smartmontools/
	cp ./smartmontools /etc/default/
	cp ./smartd.init /etc/rc3.d/S90-smartd
	cp ./smartd_warning.sh /etc/smartmontools/
fi
# set the permissions
if [ -e ${SMARTDXML} ]
then
	chown root:sys /var/svc/manifest/site/smartd.xml
	chown root:sys /etc/rc3.d/S90-smartd
	chown root:sys /etc/smartmontools/smartd_warning.sh
	chmod a+x /etc/rc3.d/S90-smartd
fi


# Import service configuration file
svccfg -v import /var/svc/manifest/site/smartd.xml

# enable the service
svcadm enable smartd

#verify the service is running
SMARTDSVCS=`svcs | grep smartd`
SVCSERROR=`svcs -xv | wc -l`
if [[ 0 -lt $SVCSERROR ]]
then
	echo "Check service configuration file and restart manually"
	exit 2
fi
if [[ $SMARTDSVCS == "online"* ]]; then
	echo "Smartd online and configured."
	echo "Complete. Exiting."
	exit 0
fi
