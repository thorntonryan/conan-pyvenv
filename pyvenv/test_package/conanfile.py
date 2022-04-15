from conans import ConanFile, tools, CMake
import os

class TestPyvenv(ConanFile):
    generators = 'pyvenv','cmake'

    def build(self):
        from pyvenv import venv
        build_env = venv(self)
        build_env.create("build_env")
        self.build_env = build_env

        build_env.setup_entry_points("pip", os.path.join(self.build_folder, "bin"))

        cmake = CMake(self)
        cmake.configure()

    def test(self):
        # just run something quick to test that we can call pip
        self.run(tools.args_to_string([self.build_env.python, '--version']))
        self.run(tools.args_to_string([self.build_env.pip, 'list']))

        # try running pip copied to bin folder
        self.run(tools.args_to_string([os.path.join(self.build_folder, "bin", "pip"), 'list']))
        cmake = CMake(self)
        cmake.test()
