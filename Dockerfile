FROM node:6

RUN curl -o /tmp/ffmpeg.tar.xz -L http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz \
 && tar xavf /tmp/ffmpeg.tar.xz ffmpeg-3.2.2-64bit-static/ffmpeg \
 && mv ffmpeg-3.2.2-64bit-static/ffmpeg /usr/local/bin/ \
 && rm -rf /tmp/ffmpeg*
RUN npm install pm2 -g

ENV NODE_ENV production
CMD ["pm2-docker", "processes.json"]
EXPOSE 20772

RUN mkdir -p /usr/src/app && git clone --depth 1 https://github.com/Chinachu/Chinachu.git /usr/src/app/
ADD processes.json /usr/src/app/processes.json
WORKDIR /usr/src/app
VOLUME /usr/src/app/data
VOLUME /usr/src/app/recorded
RUN npm install \
 && git submodule init \
 && git submodule update \
 && install -o node -g node config.sample.json config.json \
 && install -o node -g node rules.sample.json rules.json \
 && install -o node -g node -d log \
 && install -o node -g node -d data \
 && install -o node -g node -d recorded \
 && ln -sf chinachu-operator-0.pid /var/run/chinachu-operator.pid \
 && ln -sf chinachu-wui-1.pid /var/run/chinachu-wui.pid

USER node
