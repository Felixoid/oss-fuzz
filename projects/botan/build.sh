#!/bin/bash -eu
# Copyright 2016,2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# this is a temporary fix: this project cannot be built with LLVM14 new pass
# manager, so have to fall back to old pass manager.
export CFLAGS=$(echo "$CFLAGS" | sed -e 's/-O0//')
export CXXFLAGS=$(echo "$CXXFLAGS" | sed -e 's/-O0//')
export CFLAGS=$(echo "$CFLAGS" | sed -e 's/-flto/-flegacy-pass-manager -flto/')
export CXXFLAGS=$(echo "$CXXFLAGS" | sed -e 's/-flto/-flegacy-pass-manager -flto/')

cd $SRC/botan

ln -s $SRC/fuzzer_corpus .

./configure.py --cc-bin=$CXX --cc-abi-flags="$CXXFLAGS" \
               --disable-shared --disable-modules=locking_allocator \
               --unsafe-fuzzer-mode --build-fuzzers=libfuzzer \
               --without-os-features=getrandom,getentropy --with-fuzzer-lib='FuzzingEngine'

make -j$(nproc) libs
make -j$(nproc) fuzzers
make fuzzer_corpus_zip

# the seed corpus zips will also be in this directory
cp build/fuzzer/* $OUT
