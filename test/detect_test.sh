#!/bin/sh
. ${BUILDPACK_HOME}/test/helper.sh

test_always_detects() {
  detect
  assertAppDetected PredictionIO
}
