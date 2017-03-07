#!/bin/sh
. ${BUILDPACK_HOME}/test/helper.sh

pioEngineDir=""
pioSpy=""

# Create a spy script where the executable is expected
# to assert how it is called.
afterSetUp() {
  PATH=./:$PATH
  pioEngineDir="$BUILD_DIR/pio-engine"
  pioSpy="${pioEngineDir}/pio"
  mkdir -p "${pioEngineDir}"
  cat > $pioSpy <<'HEREDOC'
#!/bin/sh
set -e
echo $@
HEREDOC
  chmod +x $pioSpy

  cd $BUILD_DIR
  unset PIO_OPTS
  unset PIO_TRAIN_SPARK_OPTS
}

beforeTearDown() {
  cd $BUILDPACK_HOME
  rm $pioSpy
}

test_train_params()
{
  capture ${BUILDPACK_HOME}/bin/engine/heroku-buildpack-pio-train
  assertEquals 0 ${rtrn}
  assertEquals \
    "train -- --packages org.apache.hadoop:hadoop-aws:2.7.2" \
    "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}

test_train_params_with_pio_opts()
{
  export PIO_OPTS='--variant best.json'
  
  capture ${BUILDPACK_HOME}/bin/engine/heroku-buildpack-pio-train
  assertEquals 0 ${rtrn}
  assertEquals \
    "train --variant best.json -- --packages org.apache.hadoop:hadoop-aws:2.7.2" \
    "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}

test_train_params_with_spark_opts()
{
  export PIO_TRAIN_SPARK_OPTS='--master spark://localhost'
  
  capture ${BUILDPACK_HOME}/bin/engine/heroku-buildpack-pio-train
  assertEquals 0 ${rtrn}
  assertEquals \
    "train -- --packages org.apache.hadoop:hadoop-aws:2.7.2 --master spark://localhost" \
    "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}

test_train_params_for_old_predictionio()
{
  mkdir -p .heroku
  touch .heroku/.is_old_predictionio
  
  capture ${BUILDPACK_HOME}/bin/engine/heroku-buildpack-pio-train
  assertEquals 0 ${rtrn}
  assertEquals \
    "train -- --driver-class-path /app/lib/postgresql_jdbc.jar" \
    "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}

test_train_params_for_old_predictionio_with_pio_opts()
{
  export PIO_OPTS='--variant best.json'
  mkdir -p .heroku
  touch .heroku/.is_old_predictionio
  
  capture ${BUILDPACK_HOME}/bin/engine/heroku-buildpack-pio-train
  assertEquals 0 ${rtrn}
  assertEquals \
    "train --variant best.json -- --driver-class-path /app/lib/postgresql_jdbc.jar" \
    "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}

test_train_params_for_old_predictionio_with_spark_opts()
{
  export PIO_TRAIN_SPARK_OPTS='--master spark://localhost'
  mkdir -p .heroku
  touch .heroku/.is_old_predictionio
  
  capture ${BUILDPACK_HOME}/bin/engine/heroku-buildpack-pio-train
  assertEquals 0 ${rtrn}
  assertEquals \
    "train -- --driver-class-path /app/lib/postgresql_jdbc.jar --master spark://localhost" \
    "$(cat ${STD_OUT})"
  assertEquals "" "$(cat ${STD_ERR})"
}
