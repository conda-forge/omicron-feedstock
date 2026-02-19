#!/bin/bash
set -ex

mkdir -p _build
pushd _build

# hack rootcling calls to not set DYLD_LIBRARY_PATH
# (not needed for ROOT >= 6.38.0 where this was removed upstream)
if [[ "${target_platform}" == "osx-64" ]]; then
	patch -N -p0 -f -i $RECIPE_DIR/rootcling-dyld_library_path-hack.patch -d $PREFIX || true
fi

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
if [[ "$(uname)" != "Darwin" ]]; then
    ctest --parallel ${CPU_COUNT} --verbose
fi

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# revert hack
if [[ "${target_platform}" == "osx-64" ]]; then
	patch -R -p0 -f -i $RECIPE_DIR/rootcling-dyld_library_path-hack.patch -d $PREFIX || true
fi

# install activate/deactivate scripts
for action in activate deactivate; do
	mkdir -p ${PREFIX}/etc/conda/${action}.d
	for ext in sh csh; do
		_target="${PREFIX}/etc/conda/${action}.d/${action}-${PKG_NAME}.${ext}"
		echo "-- Installing: ${_target}"
		cp "${RECIPE_DIR}/${action}.${ext}" "${_target}"
	done
done
