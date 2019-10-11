DEBS_DIR=deb/

VERSION := $(shell cat version)

DIST_DOM0 ?= plan10

OS ?= Linux
PYTHON ?= python3

ADMIN_API_METHODS_SIMPLE = \
	admin.deviceclass.List \
	admin.vmclass.List \
	admin.Events \
	admin.backup.Execute \
	admin.backup.Info \
	admin.backup.Cancel \
	admin.label.Create \
	admin.label.Get \
	admin.label.List \
	admin.label.Index \
	admin.label.Remove \
	admin.pool.Add \
	admin.pool.Info \
	admin.pool.List \
	admin.pool.ListDrivers \
	admin.pool.Remove \
	admin.pool.Set.revisions_to_keep \
	admin.pool.volume.Info \
	admin.pool.volume.List \
	admin.pool.volume.ListSnapshots \
	admin.pool.volume.Resize \
	admin.pool.volume.Revert \
	admin.pool.volume.Set.revisions_to_keep \
	admin.pool.volume.Set.rw \
	admin.pool.volume.Snapshot \
	admin.property.Get \
	admin.property.GetDefault \
	admin.property.Help \
	admin.property.HelpRst \
	admin.property.List \
	admin.property.Reset \
	admin.property.Set \
	admin.vm.Create.AppVM \
	admin.vm.Create.DispVM \
	admin.vm.Create.StandaloneVM \
	admin.vm.Create.TemplateVM \
	admin.vm.CreateInPool.AppVM \
	admin.vm.CreateInPool.DispVM \
	admin.vm.CreateInPool.StandaloneVM \
	admin.vm.CreateInPool.TemplateVM \
	admin.vm.CreateDisposable \
	admin.vm.Kill \
	admin.vm.List \
	admin.vm.Pause \
	admin.vm.Remove \
	admin.vm.Shutdown \
	admin.vm.Start \
	admin.vm.Unpause \
	admin.vm.device.pci.Attach \
	admin.vm.device.pci.Available \
	admin.vm.device.pci.Detach \
	admin.vm.device.pci.List \
	admin.vm.device.pci.Set.persistent \
	admin.vm.device.block.Attach \
	admin.vm.device.block.Available \
	admin.vm.device.block.Detach \
	admin.vm.device.block.List \
	admin.vm.device.block.Set.persistent \
	admin.vm.device.mic.Attach \
	admin.vm.device.mic.Available \
	admin.vm.device.mic.Detach \
	admin.vm.device.mic.List \
	admin.vm.device.mic.Set.persistent \
	admin.vm.feature.CheckWithNetvm \
	admin.vm.feature.CheckWithTemplate \
	admin.vm.feature.CheckWithAdminVM \
	admin.vm.feature.CheckWithTemplateAndAdminVM \
	admin.vm.feature.Get \
	admin.vm.feature.List \
	admin.vm.feature.Remove \
	admin.vm.feature.Set \
	admin.vm.firewall.Flush \
	admin.vm.firewall.Get \
	admin.vm.firewall.Set \
	admin.vm.firewall.GetPolicy \
	admin.vm.firewall.SetPolicy \
	admin.vm.firewall.Reload \
	admin.vm.property.Get \
	admin.vm.property.GetDefault \
	admin.vm.property.Help \
	admin.vm.property.HelpRst \
	admin.vm.property.List \
	admin.vm.property.Reset \
	admin.vm.property.Set \
	admin.vm.tag.Get \
	admin.vm.tag.List \
	admin.vm.tag.Remove \
	admin.vm.tag.Set \
	admin.vm.volume.CloneFrom \
	admin.vm.volume.CloneTo \
	admin.vm.volume.Info \
	admin.vm.volume.List \
	admin.vm.volume.ListSnapshots \
	admin.vm.volume.Resize \
	admin.vm.volume.Revert \
	admin.vm.volume.Set.revisions_to_keep \
	admin.vm.volume.Set.rw \
	admin.vm.Stats \
	$(null)

ifeq ($(OS),Linux)
DATADIR ?= /var/lib/plan10
STATEDIR ?= /var/run/plan10
LOGDIR ?= /var/log/plan10
FILESDIR ?= /usr/share/plan10
endif

help:
	@echo "make DEBS                  -- generate binary deb packages"
	@echo "make DEBS-dom0             -- generate binary deb packages for Dom0"
	@echo "make update-repo-current   -- copy newly generated DEBS to plan10 apt repo"
	@echo "make update-repo-current-testing  -- same, but to -current-testing repo"
	@echo "make update-repo-unstable  -- same, but to -testing repo"
	@echo "make update-repo-installer -- copy dom0 DEBS to installer repo"
	@echo "make clean                 -- cleanup"

DEBS: DEBS-dom0

DEBS-vm:
	@true

DEBS-dom0:
	debbuild --define "_debdir $(DEBS_DIR)" -bb deb_spec/core-dom0.spec
	debbuild --define "_debdir $(DEBS_DIR)" -bb deb_spec/core-dom0-doc.spec
	deb --addsign \
		$(DEBS_DIR)/x86_64/plan10-core-dom0-$(VERSION)*.deb \
		$(DEBS_DIR)/noarch/plan10-core-dom0-doc-$(VERSION)*deb

all:
	$(PYTHON) setup.py build
	$(MAKE) -C plan10-rpc all
	# Currently supported only on xen

install:
ifeq ($(OS),Linux)
	$(MAKE) install -C linux/sysvinit
	$(MAKE) install -C linux/aux-tools
	$(MAKE) install -C linux/system-config
endif
	$(PYTHON) setup.py install -O1 --skip-build --root $(DESTDIR)
	ln -s mastervm-device $(DESTDIR)/usr/bin/mastervm-block
	ln -s mastervm-device $(DESTDIR)/usr/bin/mastervm-pci
	ln -s mastervm-device $(DESTDIR)/usr/bin/mastervm-usb
	install -d $(DESTDIR)/usr/share/man/man1
	ln -s mastervm-device.1.gz $(DESTDIR)/usr/share/man/man1/mastervm-block.1.gz
	ln -s mastervm-device.1.gz $(DESTDIR)/usr/share/man/man1/mastervm-pci.1.gz
	ln -s mastervm-device.1.gz $(DESTDIR)/usr/share/man/man1/mastervm-usb.1.gz
	$(MAKE) install -C relaxng
	mkdir -p $(DESTDIR)/etc/plan10
ifeq ($(BACKEND_VMM),xen)
	# Currently supported only on xen
	cp etc/plan10memman.conf $(DESTDIR)/etc/plan10/
endif
	mkdir -p $(DESTDIR)/etc/plan10-rpc/policy
	mkdir -p $(DESTDIR)/usr/libexec/plan10
	cp plan10-rpc-policy/plan10.FeaturesRequest.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.FeaturesRequest
	cp plan10-rpc-policy/plan10.Filecopy.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.Filecopy
	cp plan10-rpc-policy/plan10.OpenInVM.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.OpenInVM
	cp plan10-rpc-policy/plan10.OpenURL.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.OpenURL
	cp plan10-rpc-policy/plan10.VMShell.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.VMShell
	cp plan10-rpc-policy/plan10.VMRootShell.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.VMRootShell
	cp plan10-rpc-policy/plan10.NotifyUpdates.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.NotifyUpdates
	cp plan10-rpc-policy/plan10.NotifyTools.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.NotifyTools
	cp plan10-rpc-policy/plan10.GetImageRGBA.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.GetImageRGBA
	cp plan10-rpc-policy/plan10.GetRandomizedTime.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.GetRandomizedTime
	cp plan10-rpc-policy/plan10.NotifyTools.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.NotifyTools
	cp plan10-rpc-policy/plan10.NotifyUpdates.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.NotifyUpdates
	cp plan10-rpc-policy/plan10.OpenInVM.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.OpenInVM
	cp plan10-rpc-policy/plan10.StartApp.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.StartApp
	cp plan10-rpc-policy/plan10.VMShell.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.VMShell
	cp plan10-rpc-policy/plan10.UpdatesProxy.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.UpdatesProxy
	cp plan10-rpc-policy/plan10.GetDate.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.GetDate
	cp plan10-rpc-policy/plan10.ConnectTCP.policy $(DESTDIR)/etc/plan10-rpc/policy/plan10.ConnectTCP
	cp plan10-rpc-policy/admin.vm.Console.policy $(DESTDIR)/etc/plan10-rpc/policy/admin.vm.Console
	cp plan10-rpc-policy/policy.RegisterArgument.policy $(DESTDIR)/etc/plan10-rpc/policy/policy.RegisterArgument
	cp plan10-rpc/plan10.FeaturesRequest $(DESTDIR)/etc/plan10-rpc/
	cp plan10-rpc/plan10.GetDate $(DESTDIR)/etc/plan10-rpc/
	cp plan10-rpc/plan10.GetRandomizedTime $(DESTDIR)/etc/plan10-rpc/
	cp plan10-rpc/plan10.NotifyTools $(DESTDIR)/etc/plan10-rpc/
	cp plan10-rpc/plan10.NotifyUpdates $(DESTDIR)/etc/plan10-rpc/
	cp plan10-rpc/plan10.ConnectTCP $(DESTDIR)/etc/plan10-rpc/
	install plan10-rpc/plan10d-query-fast $(DESTDIR)/usr/libexec/plan10/
	install -m 0755 mastervm-tools/plan10-bug-report $(DESTDIR)/usr/bin/plan10-bug-report
	install -m 0755 mastervm-tools/plan10-hcl-report $(DESTDIR)/usr/bin/plan10-hcl-report
	install -m 0755 mastervm-tools/mastervm-sync-clock $(DESTDIR)/usr/bin/mastervm-sync-clock
	install -m 0755 mastervm-tools/mastervm-console-dispvm $(DESTDIR)/usr/bin/mastervm-console-dispvm
	for method in $(ADMIN_API_METHODS_SIMPLE); do \
		ln -s ../../usr/libexec/plan10/plan10d-query-fast \
			$(DESTDIR)/etc/plan10-rpc/$$method || exit 1; \
	done
	install plan10-rpc/admin.vm.volume.Import $(DESTDIR)/etc/plan10-rpc/
	install plan10-rpc/admin.vm.Console $(DESTDIR)/etc/plan10-rpc/
	PYTHONPATH=.:test-packages plan10-rpc-policy/generate-admin-policy \
		--destdir=$(DESTDIR)/etc/plan10-rpc/policy \
		--exclude admin.vm.Create.AdminVM \
				  admin.vm.CreateInPool.AdminVM \
		          admin.vm.device.testclass.Attach \
				  admin.vm.device.testclass.Detach \
				  admin.vm.device.testclass.List \
				  admin.vm.device.testclass.Set.persistent \
				  admin.vm.device.testclass.Available
	# sanity check
	for method in $(DESTDIR)/etc/plan10-rpc/policy/admin.*; do \
		ls $(DESTDIR)/etc/plan10-rpc/$$(basename $$method) >/dev/null || exit 1; \
	done
	install -d $(DESTDIR)/etc/plan10-rpc/policy/include
	install -m 0644 plan10-rpc-policy/admin-local-ro \
		plan10-rpc-policy/admin-local-rwx \
		plan10-rpc-policy/admin-global-ro \
		plan10-rpc-policy/admin-global-rwx \
		$(DESTDIR)/etc/plan10-rpc/policy/include/

	mkdir -p "$(DESTDIR)$(FILESDIR)"
	cp -r templates "$(DESTDIR)$(FILESDIR)/templates"
	rm -f "$(DESTDIR)$(FILESDIR)/templates/README"

	mkdir -p $(DESTDIR)$(DATADIR)
	mkdir -p $(DESTDIR)$(DATADIR)/vm-templates
	mkdir -p $(DESTDIR)$(DATADIR)/appvms
	mkdir -p $(DESTDIR)$(DATADIR)/servicevms
	mkdir -p $(DESTDIR)$(DATADIR)/vm-kernels
	mkdir -p $(DESTDIR)$(DATADIR)/backup
	mkdir -p $(DESTDIR)$(DATADIR)/dvmdata
	mkdir -p $(DESTDIR)$(STATEDIR)
	mkdir -p $(DESTDIR)$(LOGDIR)

msi:
	rm -rf destinstdir
	mkdir -p destinstdir
	$(MAKE) install \
		DESTDIR=$(PWD)/destinstdir \
		PYTHON_SITEPATH=/site-packages \
		FILESDIR=/pfiles \
		BINDIR=/bin \
		DATADIR=/plan10 \
		STATEDIR=/plan10/state \
		LOGDIR=/plan10/log
	# icons placeholder
	mkdir -p destinstdir/icons
	for i in blue gray green yellow orange black purple red; do touch destinstdir/icons/$$i.png; done
	candle -arch x64 -dversion=$(VERSION) installer.wxs
	light -b destinstdir -o core-admin.msm installer.wixobj
	rm -rf destinstdir
