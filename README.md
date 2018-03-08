# docker-nginx-proxy

> Handles HTTPS proxying with automatic self-signed serts for SSL termination.

[![GitHub tag](https://img.shields.io/github/tag/phase2/docker-nginx-proxy.svg)](https://github.com/phase2/docker-nginx-proxy) [![Docker Stars](https://img.shields.io/docker/stars/outrigger/nginx-proxy.svg)](https://hub.docker.com/r/outrigger/nginx-proxy) [![Docker Pulls](https://img.shields.io/docker/pulls/outrigger/nginx-proxy.svg)](https://hub.docker.com/r/outrigger/nginx-proxy) [![](https://images.microbadger.com/badges/image/outrigger/nginx-proxy:dev.svg)](https://microbadger.com/images/outrigger/nginx-proxy:dev 'Get your own image badge on microbadger.com')

This HTTPS proxy container is intended primarily for use with APIs (headless web services).

While many languages in which you write such services have a strong HTTP library, they
are not full-featured, production-grade HTTP servers covering all the standard needs out-of-box, and it is easier to configure nginx and rely on it's maturity than build many
of these features in custom code.

## Usage

### Docker Run

```bash
docker run --rm -it \
  -e "UPSTREAM=api.projectname.vm:3773" \
  -e "PROXY_DOMAIN=proxy.projectname.vm" \
  -l "com.dnsdock.name=proxy" \
  -l "com.dnsdock.image=projectname" \
  outrigger/nginx-proxy:1
```

### Docker Compose

```yaml
  # docker-compose run --rm proxy
  # The UPSTREAM service must be running.
  # https://proxy.projectname.vm
  proxy:
    build: outrigger/nginx-proxy:1
    container_name: projectname_http_proxy
    depends_on:
      - api
    labels:
      com.dnsdock.name: proxy
      com.dnsdock.image: projectname
    environment:
      UPSTREAM: api.projectname.vm:3773
      PROXY_DOMAIN: proxy.projectname.vm
    network_mode: bridge
```

## Features

### SSL Termination

This image was created after finding https://github.com/fsouza/docker-ssl-proxy
was very difficult to customize, but the simple untrusted SSL for local development
was still valuable.

In the future steps might be taken to facilitate more of a trust mechanism.

#### Certificates and CA location

The SSL certificate is generated using a own-ROOT-ca that is available in the
directory /etc/nginx/ca. If made available to other containers or the local
system this will serve as the basis to trust the application certificate.

#### Using Existing Certificate

You can use existing SSL certificates for your proxy domain by mounting a volume
to /etc/nginx/certs with following files inside:

* **key.pem:** Private key file
* **cert.pem:** Certificate file

The certificate generator will abort if it finds an existing key.pem file.

### gzip Compression

Responses of at least 1000 bytes will be subject to gzip compression at level 6.

### Rate Limiting

Rate Limits are more common with API-based services than other webapps. It is a request
throttle to ensure no one system monopolizes the available server resources.

This is defaulted to enabled (at 20 requests per second) but can be disabled by setting the RATE_LIMIT environment variable to "0".

In the event the limit is reached, nginx will respond with a 429 Too Many Requests response.

* https://www.nginx.com/blog/rate-limiting-nginx/
* http://nginx.org/en/docs/http/ngx_http_limit_req_module.html
* https://tools.ietf.org/html/rfc6585#section-4

### IP-based Access Example

There is a configuration file to impose IP-based Whitelisting and Blacklisting rules.
These are best handled in the nginx layer rather than in your application, as your application
is unlikely to handle it as efficiently as nginx can.

Follow the instructions in ./root/etc/nginx/conf.d/10-ip-access.conf to use it in your project.

## Environment Variables

Outrigger images use Environment Variables and [confd](https://github.com/kelseyhightower/confd)
to templatize a number of Docker environment configurations. These templates are
processed on startup with environment variables passed in via the docker run
command-line or via your `docker-compose.yml` manifest file.

* `CLIENT_MAX_BODY_SIZE`: [`20M`] Maximium size of client uploads.
* `GZIP_APPROVED_MIME_TYPES`: [``] Additional MIME types to include in gzip compression.
* `PROXY_DOMAIN`: [`www.example.com`] The domain in the SSL certificate.
* `RATE_LIMIT`: [`20`] Throttled requests per second per client IP address.
* `RATE_LIMIT_BURST_QUEUE`: [`10`] Number of requests to delay before enforcing the limit.
* `UPSTREAM`: [`proxied.example.com:80`] The target host and port for the reverse proxy.

## Maintainers

[![Phase2 Logo](https://s3.amazonaws.com/phase2.public/logos/phase2-logo.png)](https://www.phase2technology.com)
