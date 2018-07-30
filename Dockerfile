FROM node:9-alpine
MAINTAINER Jefferson Souza <hsinfo@gmail.com>

ENV ANDROID_SDK_VERSION android-sdk_r24.4.1-linux.tgz
ENV ANDROID_SDK_APIS android-19,android-21,android-22,android-23,android-24,android-25
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV ANDROID_BUILD_TOOLS_VERSION 25.0.2
ENV SASS_BINARY_NAME linux-x64-57

RUN apk -U --no-cache add tar openjdk8 python ruby git openssh g++ gcc libgcc libstdc++ linux-headers make && \
    rm /var/cache/apk/*

RUN npm install -g npm && \
    npm -g config set user $USER && \
    npm install -g yarn node-sass cordova ionic@latest && \
    echo y | cordova -v

ADD https://dl.google.com/android/${ANDROID_SDK_VERSION} /opt
RUN cd /opt && \
    tar -xf ${ANDROID_SDK_VERSION} && \
    rm -f ${ANDROID_SDK_VERSION}
RUN echo y | android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} --no-https

RUN delgroup ping

RUN addgroup jenkins && \
    adduser -D jenkins -s /bin/sh -G jenkins && \
    chown -R jenkins:jenkins /home/jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    addgroup -g 999 $USER docker && \
    sed -ri 's/(docker:x:999:)/\1jenkins/' /etc/group

RUN ssh-keygen -A

USER jenkins
RUN touch ~/.sudo_as_admin_successful
WORKDIR /home/jenkins

USER root

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
