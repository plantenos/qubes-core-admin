#!/bin/sh
chgrp plan10 /etc/xen
chmod 710 /etc/xen
chgrp plan10 /var/run/xenstored/*
chmod 660 /var/run/xenstored/*
chgrp plan10 /var/lib/xen
chmod 770 /var/lib/xen
chgrp plan10 /var/log/xen
chmod 770 /var/log/xen
chgrp plan10 /proc/xen/privcmd
chmod 660 /proc/xen/privcmd
chgrp plan10 /proc/xen/xenbus
chmod 660 /proc/xen/xenbus
chgrp plan10 /dev/xen/evtchn
chmod 660 /dev/xen/evtchn
chgrp -R plan10 /var/log/xen
chmod -R g+rX /var/log/xen
chmod g+s /var/log/xen/console
