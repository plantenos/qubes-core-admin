all:
	true

install:
	mkdir -p $(DESTDIR)/etc/xen/scripts
	cp vif-route-plan10 $(DESTDIR)/etc/xen/scripts
	cp block-snapshot $(DESTDIR)/etc/xen/scripts
	ln -s block-snapshot $(DESTDIR)/etc/xen/scripts/block-origin
	install -m 0644 -D tmpfiles-plan10.conf $(DESTDIR)/usr/lib/tmpfiles.d/plan10.conf
	install -d $(DESTDIR)/etc/logrotate.d
	install -m 0644 logrotate-plan10 \
		$(DESTDIR)/etc/logrotate.d/plan10
