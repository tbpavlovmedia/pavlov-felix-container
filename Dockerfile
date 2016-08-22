# FROM ubuntu:14.04
FROM sdempsay/docker-java8
MAINTAINER Shawn Dempsay <sdempsay@pavlovmedia.com>

##
## This is a container that puts us in shape to run OSGi microservices and web microservices inside a docker
## container. We leverage pulling the bundles down from either official sources (i.e. apache) or via Maven.
## We let felix do the initial creation of the bundles by placing them in the bundles directory instead of
## spending lots of time building out those bundle directories. Felix is good at that.
##
## For testing deployments we leverage the fileinstaller and an exposed bundle directory. That way you can
## add and remove bundles at you leisure while leaving the container (and thus felix) running.  While we
## include a startup script that check the environment for a RUN_TYPE parameter and then enable jvm
## debugging. It is something you don't want in production, so be sure to set RUNTYPE to PRODUCTION when
## deploying this container.
## More information is in the readme.md in github: https://github.com/pavlovmedia/pavlov-felix-container
##

## 
## Put apt into non-interactive mode
##
ENV DEBIAN_FRONTEND noninteractive 

##
## Setup some variables to help us keep this image up-to-date
##

# Felix
ENV felix_version 5.4.0
ENV felix_package=org.apache.felix.main.distribution-${felix_version}.tar.gz
ENV felix_base http://repo1.maven.org/maven2/org/apache/felix
ENV felix_configadmin 1.8.8
ENV felix_eventadmin 1.4.2
ENV felix_fileinstall 3.5.0
ENV felix_http_api 2.3.2
ENV felix_http_jetty 3.0.2
ENV felix_http_servlet 1.1.0
ENV felix_http_whiteboard 3.0.0
ENV felix_metatype 1.1.2
ENV felix_log 1.0.1
ENV felix_scr 2.0.2
ENV felix_webconsole 4.2.16
ENV felix_webconsole_ds 2.0.2
ENV felix_webconsole_event 1.1.2

# SLF4j
ENV slf4j_version 1.7.13

# JAX-RS and Jackson
ENV jaxrs_version 5.0
ENV jersey_version 2.22.1
ENV jackson_version 2.4.0

#
# Set up Oracle Java 8
#
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
#ADD files/webupd8team-java-trusty.list /etc/apt/sources.list.d/webupd8team-java-trusty.list
#RUN apt-get update
#RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
#RUN apt-get install -y oracle-java8-installer

## Install felix
ADD ${felix_base}/org.apache.felix.main.distribution/${felix_version}/${felix_package} /tmp/
RUN mkdir -p /opt/felix && \
    cd /opt/felix && \
    tar xvzf /tmp/${felix_package} && \
    ln -s /opt/felix/felix-framework-${felix_version} /opt/felix/current

## Initial plugin set, this will get us up with a webconle, logging, scr, and web
ADD ${felix_base}/org.apache.felix.configadmin/${felix_configadmin}/org.apache.felix.configadmin-${felix_configadmin}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.eventadmin/${felix_eventadmin}/org.apache.felix.eventadmin-${felix_eventadmin}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.fileinstall/${felix_fileinstall}/org.apache.felix.fileinstall-${felix_fileinstall}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.api/${felix_http_api}/org.apache.felix.http.api-${felix_http_api}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.jetty/${felix_http_jetty}/org.apache.felix.http.jetty-${felix_http_jetty}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.servlet-api/${felix_http_servlet}/org.apache.felix.http.servlet-api-${felix_http_servlet}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.http.whiteboard/${felix_http_whiteboard}/org.apache.felix.http.whiteboard-${felix_http_whiteboard}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.metatype/${felix_metatype}/org.apache.felix.metatype-${felix_metatype}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.log/${felix_log}/org.apache.felix.log-${felix_log}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.scr/${felix_scr}/org.apache.felix.scr-${felix_scr}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.webconsole/${felix_webconsole}/org.apache.felix.webconsole-${felix_webconsole}-all.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.webconsole.plugins.ds/${felix_webconsole_ds}/org.apache.felix.webconsole.plugins.ds-${felix_webconsole_ds}.jar /opt/felix/current/bundle/
ADD ${felix_base}/org.apache.felix.webconsole.plugins.event/${felix_webconsole_event}/org.apache.felix.webconsole.plugins.event-${felix_webconsole_event}.jar /opt/felix/current/bundle/

## Jax-RS and Jackson
ADD http://repo1.maven.org/maven2/com/eclipsesource/jaxrs/publisher/${jaxrs_version}/publisher-${jaxrs_version}.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/eclipsesource/jaxrs/jersey-all/${jersey_version}/jersey-all-${jersey_version}.jar /opt/felix/current/bundle/
#ADD http://repo1.maven.org/maven2/com/eclipsesource/jaxrs/jersey-moxy/${jersey_version}/jerseymoxy${jersey_version}.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/${jackson_version}/jackson-core-${jackson_version}.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/${jackson_version}/jackson-annotations-${jackson_version}.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/${jackson_version}/jackson-databind-${jackson_version}.jar /opt/felix/current/bundle/

## Entirely too many things use SLF4J
ADD http://repo1.maven.org/maven2/org/slf4j/slf4j-api/${slf4j_version}/slf4j-api-${slf4j_version}.jar /opt/felix/current/bundle/
ADD http://repo1.maven.org/maven2/org/slf4j/slf4j-simple/${slf4j_version}/slf4j-simple-${slf4j_version}.jar /opt/felix/current/bundle/

#
# Now expose where config manager dumps thigs so we can persist
# across starts
#

RUN echo 'felix.cm.dir=/opt/felix/current/configs' >> /opt/felix/current/conf/config.properties
RUN echo 'felix.fileinstall.start.level=2' >> /opt/felix/current/conf/config.properties
RUN echo 'org.osgi.framework.startlevel.beginning=2' >> /opt/felix/current/conf/config.properties
RUN echo 'org.osgi.framework.bootdelegation=sun.*,com.sun.*' >> /opt/felix/current/conf/config.properties
RUN mkdir -p /opt/felix/current/configs

#
# Finally expose our webports so you can use this with something like
# https://github.com/jwilder/nginx-proxy
#

EXPOSE 8080 8000
VOLUME ["/opt/felix/current/configs", "/opt/felix/current/load" ]

#
# Copy our startup script
#

COPY files/startFelix.sh /opt/felix/current/
CMD /opt/felix/current/startFelix.sh
