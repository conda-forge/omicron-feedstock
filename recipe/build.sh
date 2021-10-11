#!/bin/bash

mkdir -p _build
pushd _build

# configure
cmake \
	${SRC_DIR} \
	${CMAKE_ARGS} \
	-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
	-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen:BOOL=true \
	-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
ctest --parallel ${CPU_COUNT} --verbose

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# install activate/deactivate scripts
for action in activate deactivate; do
	mkdir -pv ${PREFIX}/etc/conda/${action}.d
	for ext in sh csh; do
		echo "-- Installing: ${action}.${ext}"
		cp -v "${RECIPE_DIR}/${action}.${ext}" "${PREFIX}/etc/conda/${action}.d/activate-${PKG_NAME}.${ext}"
	done
done
