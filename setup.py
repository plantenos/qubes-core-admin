#!/usr/bin/python3 -O
# vim: fileencoding=utf-8

import os

import setuptools
import setuptools.command.install


# don't import: import * is unreliable and there is no need, since this is
# compile time and we have source files
def get_console_scripts():
    for filename in os.listdir('./plan10/tools'):
        basename, ext = os.path.splitext(os.path.basename(filename))
        if basename == '__init__' or ext != '.py':
            continue
        yield basename.replace('_', '-'), 'plan10.tools.{}'.format(basename)

# create simple scripts that run much faster than "console entry points"
class CustomInstall(setuptools.command.install.install):
    def run(self):
        bin = os.path.join(self.root, "usr/bin")
        try:
            os.makedirs(bin)
        except:
            pass
        for file, pkg in get_console_scripts():
           path = os.path.join(bin, file)
           with open(path, "w") as f:
               f.write(
"""#!/usr/bin/python3
from {} import main
import sys
if __name__ == '__main__':
	sys.exit(main())
""".format(pkg))

           os.chmod(path, 0o755)
        setuptools.command.install.install.run(self)

if __name__ == '__main__':
    setuptools.setup(
        name='plan10',
        version=open('version').read().strip(),
        author='Invisible Things Lab',
        author_email='woju@invisiblethingslab.com',
        description='Qubes core package',
        license='GPL2+',
        url='https://www.plan10-os.org/',
        packages=setuptools.find_packages(exclude=('core*', 'tests')),
        cmdclass={
            'install': CustomInstall,
        },
        entry_points={
            'plan10.vm': [
                'AppVM = plan10.vm.appvm:AppVM',
                'TemplateVM = plan10.vm.templatevm:TemplateVM',
                'StandaloneVM = plan10.vm.standalonevm:StandaloneVM',
                'AdminVM = plan10.vm.adminvm:AdminVM',
                'DispVM = plan10.vm.dispvm:DispVM',
            ],
            'plan10.ext': [
                'plan10.ext.admin = plan10.ext.admin:AdminExtension',
                'plan10.ext.core_features = plan10.ext.core_features:CoreFeatures',
                'plan10.ext.plan10manager = plan10.ext.plan10manager:QubesManager',
                'plan10.ext.gui = plan10.ext.gui:GUI',
                'plan10.ext.r3compatibility = plan10.ext.r3compatibility:R3Compatibility',
                'plan10.ext.pci = plan10.ext.pci:PCIDeviceExtension',
                'plan10.ext.block = plan10.ext.block:BlockDeviceExtension',
                'plan10.ext.services = plan10.ext.services:ServicesExtension',
                'plan10.ext.windows = plan10.ext.windows:WindowsFeatures',
            ],
            'plan10.devices': [
                'pci = plan10.ext.pci:PCIDevice',
                'block = plan10.ext.block:BlockDevice',
                'testclass = plan10.tests.devices:TestDevice',
            ],
            'plan10.storage': [
                'file = plan10.storage.file:FilePool',
                'file-reflink = plan10.storage.reflink:ReflinkPool',
                'linux-kernel = plan10.storage.kernels:LinuxKernel',
                'lvm_thin = plan10.storage.lvm:ThinPool',
            ],
            'plan10.tests.storage': [
                'test = plan10.tests.storage:TestPool',
                'file = plan10.storage.file:FilePool',
                'file-reflink = plan10.storage.reflink:ReflinkPool',
                'linux-kernel = plan10.storage.kernels:LinuxKernel',
                'lvm_thin = plan10.storage.lvm:ThinPool',
            ],
        })
