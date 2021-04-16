#!/bin/bash

git clone --recursive "https://review.mlplatform.org/ml/ethos-u/ml-embedded-evaluation-kit"
sed -i -E 's/8.1-M.Main.dsp/cortex-m55/g' ml-embedded-evaluation-kit/scripts/cmake/bare-metal-toolchain.cmake
curl -L https://github.com/ARM-software/ML-zoo/blob/master/models/image_classification/mobilenet_v2_1.0_224/tflite_uint8/mobilenet_v2_1.0_224_quantized_1_default_1.tflite?raw=true --output mobilenet_v2_1.0_224_quantized_1_default_1.tflite
mv mobilenet_v2_1.0_224_quantized_1_default_1.tflite ml-embedded-evaluation-kit/

pushd ml-embedded-evaluation-kit
vela mobilenet_v2_1.0_224_quantized_1_default_1.tflite --accelerator-config=ethos-u55-128 --block-config-limit=0 --config scripts/vela/vela.ini --memory-mode Shared_Sram --system-config Ethos_U55_High_End_Embedded
mkdir -p build && cd build 
cmake \
    -DTARGET_PLATFORM=mps3 \
    -DTARGET_SUBSYSTEM=sse-300 \
    -DCMAKE_TOOLCHAIN_FILE=scripts/cmake/bare-metal-toolchain.cmake \
    -DUSE_CASE_BUILD=img_class \
    -Dimg_class_MODEL_TFLITE_PATH=output/mobilenet_v2_1.0_224_quantized_1_default_1_vela.tflite \
    ..
make -j8
popd

