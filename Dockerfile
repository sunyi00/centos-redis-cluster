FROM centos:7.1.1503

ENV REDIS_VERSION 3.0.2
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.2.tar.gz
ENV REDIS_DOWNLOAD_SHA1 a38755fe9a669896f7c5d8cd3ebbf76d59712002

RUN buildDeps='gcc-c++ libc6-dev tar git unzip wget libevent clang libstdc++-static'; \
    baseDeps='make gcc curl libffi-devel'; \
    set -x \
    && yum install -y epel-release \
    && yum install -y $baseDeps $buildDeps \
    && yum install -y python-devel mysql-devel python-pip \
    && pip install pip --upgrade \
    && pip install pyopenssl ndg-httpsclient pyasn1 \
    && pip install supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /usr/src/redis \
    && mkdir -p /redis \
    && cd /root/ \
    && curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
    && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -r /usr/src/redis \
    && cd /root/ \
    && curl -L https://github.com/HunanTV/redis-ctl/archive/master.zip -o redis-ctl.zip \
    && unzip redis-ctl.zip \
    && rm redis-ctl.zip \
    && cd redis-ctl-master/ \
    && pip install -r requirements.txt \
    && wget http://influxdb.s3.amazonaws.com/influxdb-0.9.0-1.x86_64.rpm \
    && rpm -ivh influxdb-0.9.0-1.x86_64.rpm \
    && rm -f influxdb-0.9.0-1.x86_64.rpm \
    && cd /root/ \
    && curl -L https://github.com/HunanTV/redis-cerberus/archive/master.zip -o redis-cerberus.zip \
    && unzip redis-cerberus.zip \
    && rm redis-cerberus.zip \
    && cd redis-cerberus-master/ \
    && make MODE=debug STATIC_LINK=1 \
    && mkdir -p /cerberus/bin /cerberus/conf \
    && cp -f cerberus /cerberus/bin/ \
    && cp -f example.conf /cerberus/conf/cerberus.conf \
    && cd /root/ \
    && rm -rf /root/redis-cerberus-master/ \
    && yum clean -y all && rm -rf /var/cache/yum/* \
    && yum remove -y $buildDeps

VOLUME /redis

EXPOSE 5000
EXPOSE 6379
EXPOSE 16379
EXPOSE 8889
