# docker-chinachu
dockerize-chiunachu

```bash
docker run \
  -d -p 20772:20772 --restart=always --name chinachu \
  -v /etc/localtime:/etc/localtime:ro \
  -v /var/run/mirakurun.sock:/var/run/mirakurun.sock:rw \
  -v /path/to/config.json:/usr/src/app/config.json \
  -v /path/to/rules.json:/usr/src/app/rules.json:rw \
  -v /path/to/data/:/usr/src/app/data/:rw \
  -v /path/to/log/:/usr/src/app/log/:rw \
  -v /path/to/recorded/:/usr/src/app/recorded/:rw \
  mhiroaki/mirakurun
```

- see also [docker-compose.yml](https://github.com/akihiro/mirakurun/blob/master/docker-compose.yml)
