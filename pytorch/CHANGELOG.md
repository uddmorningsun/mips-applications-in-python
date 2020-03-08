## Pytorch configuration and build command

Version 0.1.0
----

Released on 2020-03-08

- Build on `debian:stretch, GLIBC~2.24, python==3.7.6`, based on v1.4.0
- Build command:
```
$ CMAKE_VERBOSE_MAKEFILE=ON BUILD_BINARY=ON BLAS=OpenBLAS _GLIBCXX_USE_CXX11_ABI=ON PSIMD_SOURCE_DIR=/root/pytorch/third_party/psimd BUILD_TEST=OFF BUILD_CUSTOM_PROTOBUF=OFF Protobuf_LIBRARY=/usr/lib/x86_64-linux-gnu/libprotobuf.a Protobuf_INCLUDE_DIR=/usr/include CMAKE_BUILD_TYPE=Release python setup.py bdist_wheel --cmake
```
- Reference:
    - https://github.com/pytorch/pytorch/issues/28775
- MD5
```
846cfda37f600aefd283ab59df45ff2f  torch-1.4.0a0+21152dc-cp37-cp37m-linux_mips64.whl
```
