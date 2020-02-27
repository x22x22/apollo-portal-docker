# Dockerfile for apollo-portal-server

# Build with:
# docker build -t apollo-portal-server:v1.0.0 .

FROM ubuntu:18.04 AS Jar
WORKDIR /tmp
ARG apollo_version=1.5.1
RUN \
  env && \
  echo ${apollo_version} && \
  sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
  sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
  apt-get update -y && \
  apt-get install curl unzip -y &&  \
  curl -L -o apollo-portal.zip https://github.com/ctripcorp/apollo/releases/download/v${apollo_version}/apollo-portal-${apollo_version}-github.zip &&  \
  curl -L -o apollo-portal.zip.sha1 https://github.com/ctripcorp/apollo/releases/download/v${apollo_version}/apollo-portal-${apollo_version}-github.zip.sha1 &&  \
  unzip ./apollo-portal.zip &&  \
  cp ./apollo-portal-1.5.1.jar apollo-portal.jar

FROM openjdk:8-jre-alpine3.8


RUN \
  echo "http://mirrors.aliyun.com/alpine/v3.8/main" > /etc/apk/repositories && \
  echo "http://mirrors.aliyun.com/alpine/v3.8/community" >> /etc/apk/repositories  && \
  apk update upgrade && \
  apk add --no-cache procps curl bash tzdata && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  echo "Asia/Shanghai" > /etc/timezone && \
  mkdir -p /apollo-portal-server

ADD . /apollo-portal-server/
COPY --from=Jar /tmp/apollo-portal.jar /apollo-portal-server/apollo-portal.jar 

RUN chmod 755 /apollo-portal-server/scripts/startup-kubernetes.sh\

ENV APOLLO_PORTAL_SERVICE_NAME="service-apollo-portal-server.sre"

EXPOSE 8070

CMD ["/apollo-portal-server/scripts/startup-kubernetes.sh"]
