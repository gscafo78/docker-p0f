# Use Alpine 3.13 to avoid faccessat2 compatibility issues
FROM alpine:3.13

# Add source files
COPY ./dist /opt/p0f

# Install necessary packages
RUN apk -U --no-cache add \
                       bash \
                       build-base \
                       jansson \
                       jansson-dev \
                       libcap \
                       libpcap \
                       libpcap-dev && \
# Setup user, groups, and configurations
    addgroup -g 2000 p0f && \
    adduser -S -s /bin/bash -u 2000 -D -g 2000 p0f && \
# Set execute permissions for build.sh
    chmod +x /opt/p0f/build.sh && \
# Download and compile p0f
    cd /opt/p0f && \
    ./build.sh && \
    setcap cap_sys_chroot,cap_setgid,cap_net_raw=+ep /opt/p0f/p0f && \
# Clean up unnecessary packages and cache
    apk del --purge build-base \
                    jansson-dev \
                    libpcap-dev && \
    rm -rf /root/* && \
    rm -rf /var/cache/apk/*

# Set working directory and user
WORKDIR /opt/p0f
USER p0f:p0f

# Start p0f
CMD exec /opt/p0f/p0f -u p0f -j -o /var/log/p0f/p0f.json -i $(/sbin/ip address show | /usr/bin/awk '/inet.*brd/{ print $NF; exit }') > /dev/null
