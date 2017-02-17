#!/bin/sh
. ${BUILDPACK_HOME}/test/helper.sh

test_undecorated_release()
{
  capture ${BUILDPACK_HOME}/bin/release ${BUILD_DIR}
  assertEquals 0 ${rtrn}
  assertEquals "--- {}" "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}
