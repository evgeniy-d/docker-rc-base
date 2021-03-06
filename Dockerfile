FROM debian:jessie

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
 && for key in \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      56730D5401028683275BD23C23EFEFE93C4CFFFE \
      77984A986EBC2AA786BC0F66B01FBB92821C587A \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done

ENV NODE_VERSION 8.11.3
ENV NODE_ENV production

RUN set -x \
 && apt-get update && apt-get install -y curl ca-certificates imagemagick git bzip2 python2.7 build-essential --no-install-recommends \
 && rm -rf /var/lib/apt/lists/* \
 && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
 && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
 && gpg --verify SHASUMS256.txt.asc \
 && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
 && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
 && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
 && npm cache clear --force \
 && groupadd -g 99999 -r rocketchat \
 && useradd -u 99999 -r -g rocketchat rocketchat

RUN set -x \
 && curl "https://install.meteor.com/" | sh

RUN useradd -m -G users -s /bin/bash meteor

RUN mkdir -p /app \
 && mkdir -p /app/source \
 && mkdir -p /app/server \
 && mkdir -p /app/build

USER meteor

RUN cd /tmp && meteor --version

