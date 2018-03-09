FROM node:8-alpine as ffmpeg
RUN apk add --no-cache openssl git python make gcc g++

RUN wget -O /tmp/ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz \
 && tar xJvf /tmp/ffmpeg.tar.xz \
 && mv ffmpeg-*-64bit-static/ffmpeg /usr/local/bin/ \
 && rm -rf /tmp/ffmpeg*

FROM node:8-alpine as pm2
RUN npm install -g pm2

FROM node:8-alpine as chinachu
RUN apk add --no-cache openssl git python make gcc g++
WORKDIR /usr/src/app
RUN git clone https://github.com/Chinachu/Chinachu.git .

ENV NODE_ENV production

RUN git submodule init
RUN git submodule update
RUN npm install
RUN npm update

RUN install -o node -g node config.sample.json config.json
RUN install -o node -g node rules.sample.json rules.json
RUN install -o node -g node -d log data recorded

FROM node:8-alpine
COPY --from=ffmpeg /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=pm2 /usr/local/lib/node_modules/pm2 /usr/local/lib/node_modules/pm2
RUN mkdir -p /usr/local/var/run /usr/local/var/log \
 && chown node:node /usr/local/var/run /usr/local/var/log \
 && ln -s ../lib/node_modules/pm2/bin/pm2-runtime /usr/local/bin/ \
 && ln -s ../lib/node_modules/pm2/bin/pm2 /usr/local/bin/

COPY --from=chinachu /usr/src/app /usr/src/app

WORKDIR /usr/src/app
VOLUME /usr/src/app/data
VOLUME /usr/src/app/recorded
VOLUME /usr/local/var/log/
CMD ["pm2-runtime", "processes.json"]
EXPOSE 20772
USER node
