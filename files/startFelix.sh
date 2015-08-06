#!/bin/bash

##
## A script to start felix up. You can customize this to taste so that starting
## things up can be controlled by the environment.
##

# 
# Check the docker environment for RUNTYPE
# By default this is DEV which turns on JVM debugging. Set it to anything else
# to be running a production start without debugging on
#
if [ -z "$RUNTYPE" ]; then
    RUNTYPE=DEV
fi

JVM_OPTIONS=""

case $RUNTYPE in
  DEV)
    # Only enable debugging in dev mode
    JVM_OPTIONS="$JVM_OPTIONS -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"
    # We will also do JMX in debugging mode
    JVM_OPTIONS="$JVM_OPTIONS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9000 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
  ;;
  *)
  ;;
esac

# Fire up felix
pushd /opt/felix/current && java $JVM_OPTIONS -jar bin/felix.jar
