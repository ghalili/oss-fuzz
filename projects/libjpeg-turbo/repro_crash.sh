#!/bin/bash
set -euo pipefail

# Step 1: Setup workspace
mkdir -p ~/crash_repro
cd ~/crash_repro

# Step 2: Download crashing input
wget -O crash.jpg "https://oss-fuzz.com/download?testcase_id=5483940396007424"

# Step 3: Clone libjpeg-turbo if not present
if [ ! -d libjpeg-turbo ]; then
  git clone https://github.com/ghalili/libjpeg-turbo.git
fi
cd libjpeg-turbo

# Step 4: Build libjpeg-turbo with UBSAN
mkdir -p build
cd build
cmake -G"Unix Makefiles" \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_FLAGS="-fsanitize=undefined -g" ..
make -j$(nproc)

# Step 5: Copy repro.c and compile it
cp ../repro.c .
clang -fsanitize=undefined -I../ -I../src -o repro repro.c -L. -ljpeg

# Step 6: Run crash repro
./repro ../../crash.jpg

