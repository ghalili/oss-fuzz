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

# Step 5: Compile the PoC from original location

clang -fsanitize=undefined \
  -Ilibjpeg-turbo -Ilibjpeg-turbo/src \
  -o repro projects/libjpeg-turbo/repro.c \
  -Llibjpeg-turbo/build -ljpeg
cd projects/libjpeg-turbo/
# Step 6: Run and reproduce the crash
./repro ~/crash_repro/crash.jpg

