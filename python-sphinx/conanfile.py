from conans import ConanFile
import os

class SphinxConan(ConanFile):
    name = "python-sphinx"
    version = "4.4.0"
    url = "https://github.com/thorntonryan/conan-pyvenv/python-sphinx"
    homepage = "http://www.sphinx-doc.org"
    description = "Sphinx is used to generate the help documentation"
    settings = "os_build", "arch_build"
    build_requires = [
        'pyvenv/0.3.1'
    ]

    # python venvs are not relocatable, so we will not have binaries for this on artifactory. Just build it on first use
    build_policy = "missing"
    exports_sources = [ "SphinxMacros.cmake", "python-sphinx-config.cmake" ]

    def package(self):
        from pyvenv import venv
        venv = venv(self)
        venv.create(folder=os.path.join(self.package_folder))

        self.run('{pip} install sphinx=={version}'.format(pip=venv.pip, version=self.version))
        self.run('{pip} install sphinx-rtd-theme==0.5.2'.format(pip=venv.pip))
#        self.run(tools.args_to_string([venv.pip, 'install', 'recommonmark==0.5.0']))
        self.copy("*.cmake", dst="Modules")

        venv.setup_entry_points("sphinx", os.path.join(self.package_folder,"bin"))

    def package_info(self):
        self.cpp_info.builddirs = [os.path.join(self.package_folder, 'Modules')]
