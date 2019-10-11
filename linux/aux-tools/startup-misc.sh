#!/bin/sh

# Misc dom0 startup setup

/usr/lib/plan10/fix-dir-perms.sh
DOM0_MAXMEM=$(/usr/sbin/xl list 0 | tail -1 | awk '{ print $3 }')
xenstore-write /local/domain/0/memory/static-max $[ $DOM0_MAXMEM * 1024 ]

xl sched-credit -d 0 -w 2000
cp /var/lib/plan10/plan10.xml /var/lib/plan10/backup/plan10-$(date +%F-%T).xml

/usr/lib/plan10/cleanup-dispvms

# Hide mounted devices from qubes-block list (at first udev run, only / is mounted)
udevadm trigger --action=change --subsystem-match=block
