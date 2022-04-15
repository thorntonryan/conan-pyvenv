## Description

Repository to demonstrate capability outlined by
[conan-io/conan#8626](https://github.com/conan-io/conan/issues/8626)

## Setup

### Prerquisites

* CMake
* Ninja

Both CMake and Ninja must be in PATH.

### Setup

```sh
$ conan create ./pyvenv/conanfile.py 
$ conan create ./python-sphinx/conanfile.py 
```

### Example

```sh
$ cmake -G Ninja -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
$ cmake --build . --target quickstart
$ cmake --build . --target documentation.html
```


