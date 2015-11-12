FROM b.gcr.io/tensorflow/tensorflow-full
MAINTAINER Brody Huval <brodyh@stanford.edu>

#### From nvidia-docker/ubuntu-14.04/cuda/7.0/Dockerfile ####
RUN apt-get update && apt-get install -y wget

RUN wget -q -O - http://developer.download.nvidia.com/compute/cuda/repos/GPGKEY | apt-key add - && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get update

ENV CUDA_VERSION 7.0
LABEL com.nvidia.cuda.version="7.0"

RUN apt-get install -y --no-install-recommends --force-yes "cuda-toolkit-7.0"

RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

#### Install cudnn v2 ####
COPY cudnn/cudnn-6.5-linux-x64-v2/libcudnn.so /usr/local/cuda/lib64/libcudnn.so
COPY cudnn/cudnn-6.5-linux-x64-v2/libcudnn.so.6.5 /usr/local/cuda/lib64/libcudnn.so.6.5
COPY cudnn/cudnn-6.5-linux-x64-v2/libcudnn.so.6.5.48 /usr/local/cuda/lib64/libcudnn.so.6.5.48
COPY cudnn/cudnn-6.5-linux-x64-v2/cudnn.h /usr/local/cuda/include/cudnn.h

#### uninstall base tensorflow and reinstall it with cuda ####
COPY configure-cuda /tensorflow/configure-cuda
RUN pip uninstall -y tensorflow \
    && cd /tensorflow \
    && ./configure-cuda \
    && bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package \
    && bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg \
    && pip install /tmp/tensorflow_pkg/tensorflow-0.5.0-cp27-none-linux_x86_64.whl
