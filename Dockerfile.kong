FROM kong:2.8

COPY kong.conf /etc/kong/

USER root

COPY ./plugins/check-header /custom-plugins/check-header

WORKDIR /custom-plugins/check-header

RUN luarocks make

USER kong
