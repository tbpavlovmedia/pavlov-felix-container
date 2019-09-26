FROM ubuntu:18.04
MAINTAINER Shawn Dempsay <sdempsay@pavlovmedia.com>

##
## This is a container that puts us in shape to run OSGi microservices and web microservices inside a docker
## container. We leverage pulling the bundles down from either official sources (i.e. apache) or via Maven.
## We let felix do the initial creation of the bundles by placing them in the bundles directory instead of
## spending lots of time building out those bundle directories. Felix is good at that.
##
## For testing deployments we leverage the fileinstaller and an exposed bundle directory. That way you can
## add and remove bundles at you leisure while leaving the container (and thus felix) running.
##
## More information is in the readme.md in github: https://github.com/pavlovmedia/pavlov-felix-container
##

## 
## Put apt into non-interactive mode
##
ENV DEBIAN_FRONTEND noninteractive 

##
# Set up Open JDK8
#
# RUN apt-get update && apt-get install -y openjdk-8-jre-headless openjdk-8-jdk-headless wget
# RUN apt-get update && apt-get install -y default-jdk wget
RUN apt-get update && apt-get install -y openjdk-11-jre-headless openjdk-11-jdk-headless wget nano

# Install Felix
ENV felix_version 6.0.3
ENV felix_package=org.apache.felix.main.distribution-${felix_version}.tar.gz
ENV felix_base http://repo1.maven.org/maven2/org/apache/felix

# ADD ${felix_base}/org.apache.felix.main.distribution/${felix_version}/${felix_package} /tmp
RUN wget ${felix_base}/org.apache.felix.main.distribution/${felix_version}/${felix_package} -O /tmp/${felix_package}
RUN ls /tmp
RUN mkdir -p /opt/felix && \
    cd /opt/felix && \
    tar xvzf /tmp/${felix_package} && \
    ln -s /opt/felix/felix-framework-${felix_version} /opt/felix/current

# We set up configuration here so that our obr installs go nicely
ADD files/config.properties /opt/felix/current/conf/
ADD files/system.properties /opt/felix/current/conf/
ADD files/logging.properties /opt/felix/current/conf/

#
# Now expose where config manager dumps things so we can persist
# across starts
#
RUN mkdir -p /opt/felix/current/configs

#
# Add OBR repositories for installation
#
ADD files/install.gogo /tmp
ADD files/felix.repository /tmp/felix/repository.xml
ADD files/jaxrs.repository /tmp/jaxrs/repository.xml
ADD files/swagger.repository /tmp/swagger/repository.xml
ADD files/slf4j.repository /tmp/slf4j/repository.xml
# ADD https://raw.githubusercontent.com/pavlovmedia/osgi-jaxrs-services/master/obr/repository.xml /tmp/pavlovjax/repository.xml
ADD files/pavlovjax/ /tmp/pavlovjax/
ADD files/reflections/ /tmp/reflections/
ADD files/com.pavlovmedia.oss.osgi.gogo-1.0.2.jar /opt/felix/current/bundle

#
# TEMPORARY - STORE REPOS FOR SCR AND TESTING
#
RUN mkdir -p /opt/felix/current/repos
ADD files/jaxrs.repository /opt/felix/current/repos/jaxrs/repository.xml
ADD files/felixbundlerepository/ /opt/felix/current/repos/felixbundlerepository/

#
# Install bundles with OBR
#
WORKDIR /opt/felix/current
RUN java -Dgosh.args="/tmp/install.gogo" -jar bin/felix.jar

#
# Finally expose our webports so you can use this with something like
# https://github.com/jwilder/nginx-proxy
#
EXPOSE 8080 8000
VOLUME ["/opt/felix/current/configs", "/opt/felix/current/load" ]

# You can override these at runtime, and you are encouraged to turn off debugger support in production
#ENV JVM_OPTIONS="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"
ENV JVM_OPTIONS="-Xdebug -agentlib:jdwp=transport=dt_socket,address=*:8000,server=y,suspend=n"

CMD exec java $JVM_OPTIONS -jar bin/felix.jar
