from conans import ConanFile, tools
from conans.model import Generator

import os
import re
from pyvenv import venv

class PyvenvConanFile(ConanFile):
    name = "pyvenv"
    version = "0.3.1"
    description = "Generates Python venv based on Python hosting Conan"
    url = "https://github.com/thorntonryan/conan-pyvenv/pyvenv"
    exports = ['pyvenv.py']

    no_copy_source = True

    def package_info(self):
        self.env_info.PYTHONPATH.append(os.path.dirname(__file__))

class pyvenv(Generator):
    @property
    def filename(self):
        pass

    @property
    def content(self):
        pip_requirements = []
        for dep_name, user_info in self.conanfile.deps_user_info.items():
            if 'pyvenv_pip_requirements' in user_info.vars:
                pip_requirements.append(os.path.join(self.conanfile.deps_cpp_info[dep_name].rootpath, user_info.pyvenv_pip_requirements))

        output_pyvenv = venv(self.conanfile)
        # clear=True because Conan generators typically overwrite the contents completely
        # in order to remove any trace of previously installed packages, files, etc.
        output_pyvenv.create(os.path.join(self.output_path, "pyvenv"), clear=True)

        if pip_requirements:
            self.conanfile.run(tools.args_to_string([output_pyvenv.pip, 'install', *(arg for requirements in pip_requirements for arg in ('-r',requirements))]))

        def import_executable(name, **properties):
            if not 'IMPORTED_LOCATION' in properties:
                try:
                    path = output_pyvenv.which(name, required=True)
                except FileNotFoundError as e:
                    self.conanfile.output.warn("pyvenv(Generator): FileNotFoundError: {e} (omitted pyvenv::{name} from pyvenv-config.cmake)".format(name=name,e=e))
                    return ""
                else:
                    properties['IMPORTED_LOCATION'] = cmake_path(path)


            cmake_properties = ["        %s %s" % (cmake_escape(prop_name), cmake_quoted(prop_val))
                                for prop_name, prop_val in properties.items() if not prop_val is None]
            return """
IF(NOT TARGET pyvenv::{name})
    add_executable(pyvenv::{name} IMPORTED)
    set_target_properties(pyvenv::{name} PROPERTIES
{properties}
    )
ENDIF()
""".format(name=name, properties='\n'.join(cmake_properties))

        pyvenv_config = """ # Creates python3 venv imported target
# uses same version of Python as Conan client
"""
        pyvenv_config += import_executable('python', IMPORTED_LOCATION=cmake_path(output_pyvenv.python))

        entry_points = output_pyvenv.entry_points()
        for name in entry_points.get('console_scripts',[]):
            pyvenv_config += import_executable(name)
        for name in entry_points.get('gui_scripts',[]):
            pyvenv_config += import_executable(name, WIN32_EXECUTABLE='ON')

        return { "pyvenv/cmake/pyvenv-config.cmake": pyvenv_config }

# and https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#escape-sequences
escape_encoded = { '\t': r'\t', '\r': r'\r', '\n':r'\n' }
escape_identity = re.compile('[^A-Za-z0-9_;]')

# See https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#quoted-argument
def cmake_quoted(string):
    def quoted_element(c):
        if c in ('\\', '"'):
            return '\\' + c
        if c in escape_encoded: #cosmetic, but I prefer escaping these, and it's allowed
            return escape_encoded[c]
        else:
            return c

    return '"' + ''.join(quoted_element(c) for c in string) + '"'

def cmake_escape(string):
    def escape_character(c):
        if c in escape_encoded:
            return escape_encoded[c]
        elif escape_identity.match(c):
            return '\\' + c
        else:
            return c

    return ''.join(escape_character(c) for c in string)

# as in FILE(TO_CMAKE_PATH ...)
def cmake_path(path):
    path = ';'.join(path.split(os.pathsep))
    return path.replace(os.path.sep,'/')
