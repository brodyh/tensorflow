#!/bin/bash

GPU=0 ./nvidia-docker run -it --rm  -v `pwd`:/tensorflow -w /tensorflow tensorflow:cuda /bin/bash
