FROM cloudbees/java-build-tools:2.1.0

USER root

# Install Docker client
ARG DOCKER_VERSION=1.13.1
ARG DOCKER_COMPOSE_VERSION=1.14.0
RUN apt-get update && apt-get install tar curl git \
    && curl -fsSL https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz | tar --strip-components=1 -xz -C /usr/local/bin docker/docker

RUN curl -fsSL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

ARG JENKINS_REMOTING_VERSION=3.12

# See https://github.com/jenkinsci/docker-slave/blob/2.62/Dockerfile#L32
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave

# Angular CLI
RUN npm install --global @angular/cli

RUN groupadd docker
RUN usermod -a -G docker jenkins
RUN chmod a+rwx /home/jenkins
WORKDIR /home/jenkins
USER jenkins

RUN docker --version
RUN docker-compose --version

ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]
