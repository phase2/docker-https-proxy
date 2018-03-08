FROM outrigger/servicebaselight

LABEL maintainer "Phase2 <outrigger@phase2technology.com>"

# Install packages.
RUN apk add --update --no-cache nginx openssl gettext curl tzdata

# Create an nginx user for nginx.
#RUN 
#    chown -R nginx:nginx /var/lib/nginx && \
#    mkdir -p /run/nginx

# Set default values.
ENV CLIENT_MAX_BODY_SIZE=20M \
    # Space-delimited list of MIME types to include in gzip compression configuration.
    GZIP_APPROVED_MIME_TYPES="" \
    PROXY_DOMAIN=www.example.com \
    # Requests per second a given client IP address is permitted.
    RATE_LIMIT=20 \
    # How many requests in excess of the rate limit will be pulled on a queued delay
    # before further traffic is given the 422 response.
    RATE_LIMIT_BURST_QUEUE=10 \
    UPSTREAM=proxied.example.com:80 \
    CONFD_VERSION=0.14.0 \
    CONFD_OPTS='--backend=env --onetime'

# Install confd.
RUN curl -L "https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64" > /usr/bin/confd && \
    chmod +x /usr/bin/confd

COPY root /

# Forward request and error logs to Docker log collector.
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 443
