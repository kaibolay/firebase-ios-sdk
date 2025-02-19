#!/bin/bash

# Copyright 2022 Google LLC
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

# Example usage:
# ./build_protos <path to nanopb>

# Dependencies: git, protobuf, python-protobuf, pyinstaller

readonly DIR="$( git rev-parse --show-toplevel )"

# Current release of nanopb being used  to build the CCT protos
readonly NANOPB_VERSION="0.3.9.8"
readonly NANOPB_TEMPDIR="${DIR}/FirebaseSessions/nanopb_temp"

readonly LIBRARY_DIR="${DIR}/FirebaseSessions/Sources/"
readonly PROTO_DIR="${DIR}/FirebaseSessions/ProtoSupport/Protos/"
readonly PROTOGEN_DIR="${DIR}/FirebaseSessions/Protogen/"

rm -rf "${NANOPB_TEMPDIR}"

echo "Downloading nanopb..."
git clone --branch "${NANOPB_VERSION}" https://github.com/nanopb/nanopb.git "${NANOPB_TEMPDIR}"

echo "Building nanopb..."
pushd "${NANOPB_TEMPDIR}"
./tools/make_mac_package.sh
GIT_DESCRIPTION=`git describe --always`-macosx-x86
NANOPB_BIN_DIR="dist/${GIT_DESCRIPTION}"
popd

echo "Removing existing protos..."
rm -rf "${PROTOGEN_DIR}/*"

echo "Generating protos..."
python "${DIR}/FirebaseSessions/ProtoSupport/proto_generator.py" \
  --nanopb \
  --protos_dir="${PROTO_DIR}" \
  --pythonpath="${NANOPB_TEMPDIR}/${NANOPB_BIN_DIR}/generator" \
  --output_dir="${PROTOGEN_DIR}" \
  --include="${PROTO_DIR}"

rm -rf "${NANOPB_TEMPDIR}"

RED='\033[0;31m'
NC='\033[0m'
echo ""
echo ""
echo -e "${RED}Important: Any new proto fields of type string, repeated, or bytes must be specified in the sessions.options file${NC}"
echo ""
echo ""
