ARG S6_ARCH
FROM oznu/s6-node:12.14.1-${S6_ARCH:-amd64}

RUN apk add --no-cache git python make g++ avahi-compat-libdns_sd avahi-dev dbus \
    iputils sudo nano pkgconfig\
  && chmod 4755 /bin/ping \
  && mkdir /homebridge \
  && npm set global-style=true \
  && npm set package-lock=false

ENV LIBOPENZWAVE_VERSION=1.6
RUN cd /root && git clone https://github.com/OpenZWave/open-zwave.git open-zwave \
  && cd open-zwave && make install \
  && ln -s /usr/local/lib64/libopenzwave.so /usr/local/lib/libopenzwave.so \
  && ln -s /usr/local/lib64/libopenzwave.so.${LIBOPENZWAVE_VERSION} /usr/local/lib/libopenzwave.so.${LIBOPENZWAVE_VERSION} \
  && ldconfig \ 
  && rm -rf /root/open-zwave

ENV HOMEBRIDGE_VERSION=0.4.50
RUN npm install -g --unsafe-perm homebridge@${HOMEBRIDGE_VERSION}

ENV CONFIG_UI_VERSION=4.9.0 HOMEBRIDGE_CONFIG_UI=0 HOMEBRIDGE_CONFIG_UI_PORT=8080
RUN npm install -g --unsafe-perm homebridge-config-ui-x@${CONFIG_UI_VERSION}

WORKDIR /homebridge
VOLUME /homebridge

COPY root /

ARG AVAHI
RUN [ "${AVAHI:-1}" = "1" ] || (echo "Removing Avahi" && \
  rm -rf /etc/services.d/avahi \
    /etc/services.d/dbus \
    /etc/cont-init.d/40-dbus-avahi)
