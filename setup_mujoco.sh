git submodule update --init --recursive
SOURCE_DIR=$PWD
INSTALL_DIR=$SOURCE_DIR/custom/install

# install mujoco locally
cd $SOURCE_DIR/third_party/mujoco
git checkout main
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR
cmake --build . -j$(($(nproc) - 2))
make install
