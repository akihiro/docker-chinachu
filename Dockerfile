FROM node:8-alpine

RUN apk add -U
RUN apk add openssl git python make gcc g++

RUN wget -O /tmp/ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz \
 && tar xJvf /tmp/ffmpeg.tar.xz ffmpeg-3.4.1-64bit-static/ffmpeg \
 && mv ffmpeg-3.4.1-64bit-static/ffmpeg /usr/local/bin/ \
 && rm -rf /tmp/ffmpeg*

RUN npm install -g pm2

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
COPY --from=0 /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=0 /usr/src/app /usr/src/app
COPY --from=0 /usr/local/lib/node_modules/pm2 /usr/local/lib/node_modules/pm2
RUN ln -s /usr/local/lib/node_modules/pm2/bin/pm2-runtime /usr/local/bin/
RUN ln -s /usr/local/lib/node_modules/pm2/bin/pm2 /usr/local/bin/

WORKDIR /usr/src/app
VOLUME /usr/src/app/data
VOLUME /usr/src/app/recorded
VOLUME /usr/local/var/log/
CMD ["pm2-runtime", "processes.json"]
EXPOSE 20772
USER node
