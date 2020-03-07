## Tensorflow configuration and build command

Version 0.1.0
----

Released on 2020-03-04

- Build on `debian:stretch, GLIBC~2.24, python==3.7.6, Keras-Preprocessing==1.1.0, numpy==1.18.1`
- Main `bazel build` parameters:
```
$ bazel build --config=noaws //tensorflow/tools/pip_package:build_pip_package --define=tensorflow_mkldnn_contraction_kernel=0 --copt=-mxgot --copt=-mlong-calls --linkopt=-lstdc++
```
About disable MKL-DNN, see: https://git.codingcafe.org/Mirrors/tensorflow/tensorflow/commit/7c9323bedc48c98be3c07b72ec1d6f4dccdefb35
- Reference:
    - https://github.com/tensorflow/tensorflow/issues/36896
- MD5
```
4108e7846633005a4bfa256e82615c40  tensorflow-1.14.0-cp37-cp37m-linux_mips64.whl
8c02a5da6cb80f552c7fd5a76bfd9075  tensorflow-2.0.0-cp37-cp37m-linux_mips64.whl
```
