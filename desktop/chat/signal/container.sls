{% from "containers/lib.sls" import container %}

include:
  - containers

{#
sudo x11docker --podman --cap-default --hostdisplay --gpu --webcam --pulseaudio \
  --dbus --clipboard -- \
  localhost/signal-desktop
#}

{% load_yaml as defaults %}
name: signal-desktop-build
image: signal-desktop
tag: latest
type: build
build:
  source: .
files:
  build/Dockerfile:
    contents: |
      FROM debian:buster

      # install dependencies
      RUN apt-get update
      RUN apt-get install -y curl gnupg libx11-xcb1

      # install signal
      RUN curl -s https://updates.signal.org/desktop/apt/keys.asc | apt-key add -
      RUN echo 'deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main' >/etc/apt/sources.list.d/signal-xenial.list
      RUN apt-get update
      RUN apt-get install -y signal-desktop
      RUN chmod u+s /opt/Signal/chrome-sandbox

      # create the unprivileged user
      RUN useradd -m signal
      USER signal
      WORKDIR /home/signal

      # start signal
      CMD signal-desktop
{% endload %}

{% set settings=salt['grains.filter_by']({'default': defaults},
    grain='default', default= 'default', merge= salt['pillar.get']('signal', {})) %}

{{ container(settings) }}
