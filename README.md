pavlov-felix-container
----------------------

This project is a docker container to help get moving quickly running and OSGi system
using Apache Felix.

It starts on a ubunutu 16.04 lts image, adds OpenJDK Java 8, and then sets up Felix with
a number of common bundles that are used by Pavlov Media.

It also sets up a number of things that you can use to make it convient to run with Docker.

First you can remap /opt/felix/current/configs to a local directory to persist your
config admin settings. You can also remap /opt/felix/current/load to a local directory
and allow fileinstaller to help you manage bundles during testing phases.

By default the container will run in debugging mode which allows you to connect a remote
debugger on port 8000 (assuming you map that port). If you don't want to be in debugging
mode, make sure to set the RUNTYPE enviroment value to PRODUCTION, and then it won't
start java with the debugger on.

Be sure to expose port 8080 so you can use the web side.

Here is an example of running this in debug mode:

~~~
docker run -t -i -v /tmp/load:/opt/felix/current/load -v /tmp/settings:/opt/felix/current/configs -p 8000:8000 -p 8080:8080 pavlovmedia/pavlov-felix-container
~~~
