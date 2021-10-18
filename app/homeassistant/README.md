# home-assistant via MQTT

Components:
+ **Mosquitto** as a MQTT-Server
+ **Zigbee2MQTT** to bridge Zigbee events and controls Zigbee devices via MQTT
+ **Homeassistant** connecting to zigbee devices via MQTT to zigbee2mqtt
+ **AppDaemon** for advanced homeassistant automation
+ **Rhasspy** as voice assistant for controlling homeassistant via voice
+ **podman** and **podman-compose** as container infrastructure

## Info

### Zigbee

+ Wireless Controller Coverage: Highly recommended: Male to female USB extension cable
+ Groups, Scenes and Bindings are stored on the target device
+ Groups: By using Zigbee groups you can control multiple devices simultaneously with one command.
+ Scenes: Scenes allow to quickly set certain states for a device or group. Most of the time this is used for bulbs or a group of bulbs as it allows to set a certain color and brightness with a single command.
+ Binding: Zigbee has support for binding which makes it possible that devices can directly control each other without the intervention of Zigbee2MQTT or any home automation software.
+ When a devices is being bound to, Zigbee2MQTT will automatically configure reporting for these devices. This will make the device report state changes when the state is changed through a bound device. In order for this feature to work, the device has to support it.

#### Re-Pairing

+ OSRAM/LEDVANCE Lights
  + 5 sec on, 5 sec off, repeat 5-6 times, bulb will blink on success

+ EnOcean PTM 215Z Pushbutton transmitter
  + This device has 4 buttons: Nr/Button/Position
    + 1:A0=top left , 2:A1=bottom left , 3:B0=top right , 4:B1=bottom right
  + To pair it, hold the corresponding button for that channel for 7 seconds or more.
    + Button/Channel: A0=15 , A1=20 , B0=11 , B1=25

#### Devices

+ thermal sensor array:
  + https://www.omron.com/global/en/media/press/2012/06/e0627.html
  + https://www.sparkfun.com/products/14607

### Home Assistant

+ more adaptive lightning:
  + https://github.com/basnijholt/adaptive-lighting

## example pillar

```yaml
homeassistant:
  compose:
    environment:
      RHASSPY_PROFILE: de
      ZB_ADAPTER: /dev/ttyUSB0
  config:
    hass:
      homeassistant:
        # Name of the location where Home Assistant is running
        name: Home
        # latitude+longitude+elevation=Stephansdom/Vienna
        latitude: 48.20849
        longitude: 16.37315
        # Altitude above sea level in meters
        elevation: 172
        # List of time zones: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
        time_zone: Europe/Vienna
        # metric for Metric (meter, °celcius), imperial for Imperial (miles, °fahrenheit)
        unit_system: metric
    zigbee2mqtt:
      configuration:
        serial:
          adapter: deconz
        permit_join: true
        advanced:
          channel: 11
          # 16 bit pan_id: printf "0x%s" "$(openssl rand -hex 2)"
          pan_id: 0x1a62
          # 64 bit pan_id: printf "[%s]" "$(openssl rand -hex 8 | sed -r "s/(..)/0x\1, /g")"
          ext_pan_id: [0xDD, 0xDD, 0xDD, 0xDD, 0xDD, 0xDD, 0xDD, 0xDD]
          # network encryption key, will improve security (Note: changing requires repairing of all devices) (default: shown below)
          # 128 bit network_key: printf "[%s]" "$(openssl rand -hex 16 | sed -r "s/(..)/0x\1, /g")"
          network_key: [1, 3, 5, 7, 9, 11, 13, 15, 0, 2, 4, 6, 8, 10, 12, 13]
      devices:
        'deviceid':
          friendly_name: friendly-name
      groups:
        '1':
          friendly_name: friendly-group-name
    appdaemon:
      appdaemon:
        # latitude+longitude+elevation=Stephansdom/Vienna
        latitude: 48.20849
        longitude: 16.37315
        elevation: 172
        time_zone: Europe/Vienna
        plugins:
          HASS:
            token:
    rhasspy:
      home_assistant:
        access_token:
      speech_to_text: {# pocketsphinx, kaldi, deepspeech, remote, command, or dummy #}
        system: deepspeech
      intent: {# fsticuffs, fuzzywuzzy, rasa, remote, adapt, command, or dummy #}
        system: fsticuffs
      text_to_speech: {# espeak, flite, picotts, marytts, nanotts, opentts, wavenet	larynx, command, remote, command, hermes, or dummy #}
        system: larynx
      wake: {# raven, pocketsphinx, snowboy, precise, porcupine, command, hermes, or dummy #}
        system: porcupine
      microphone: {# audio recording system (pyaudio, arecord, gstreamer, or dummy) #}
        system: arecord
      sounds: {# sound output system (aplay, command, remote, hermes, or dummy) #}
        system: aplay
      handle: {# which intent handling system to use (hass, command, remote, command, or dummy #}
        system: hass
      dialogue: {# which dialogue manager to use (rhasspy, hermes, or dummy) #}
        system: rhasspy
```

### Notes

+ settings for all devices in device_options, devices, groups:

```yaml
friendly_name:
  Used in the MQTT topic of a device.
  By default this is the device ID (e.g. 0x00128d0001d9e1d2).
retain:
  Retain MQTT messages of this device (default false).
retention:
  Sets the MQTT Message Expiry in seconds e.g. retention: 900 = 15 minutes
  (default: not enabled). Make sure to set mqtt.version to 5 (see mqtt configuration above)
qos:
  QoS level for MQTT messages of this device. What is QoS?
homeassistant:
  Allows to override values of the Home Assistant discovery payload. See example below.
debounce:
  Debounces messages of this device. When setting e.g. debounce: 1 and
  a message from a device is received, Zigbee2MQTT will not immediately
  publish this message but combine it with other messages received in that same
  second of that device. This is handy for e.g. the WSDCGQ11LM which publishes
  humidity, temperature and pressure at the same time but as 3 different messages.
debounce_ignore:
  Protects unique payload values of specified payload properties from overriding
  within debounce time. When setting e.g. debounce: 1 and
  debounce_ignore: - action every payload with unique action value will be
  published. This is handy for e.g. the E1744 which publishes multiple messages
  in short time period after one turn and debounce option without
  debounce_ignore publishes only last payload with action rotate_stop. On the
  other hand debounce: 1 with debounce_ignore: - action will publish all unique
  action messages, at least two (e.g. action: rotate_left and action: rotate_stop)
retrieve_state:
  (DEPRECATED) Retrieves the state after setting it. Should only be enabled when
  the reporting feature does not work for this device.
filtered_attributes:
  Allows to prevent certain attributes from being published. When a device would
  e.g. publish {"temperature": 10, "battery": 20} and you set
  filtered_attributes: ["battery"] it will publish {"temperature": 10}.
optimistic:
  Publish optimistic state after set, e.g. when a brightness change command
  succeeds Zigbee2MQTT assumes the brightness of the device changed and will
  publish this (default true).
filtered_optimistic:
  Same as the filtered_attributes option but only applies to the optimistic
  published attributes. Has no effect when optimistic: false is set.
  Example: filtered_optimistic: ["color_mode", "color"].
```

+ settings for lights
```yaml
set_transition: 1
# set default transition time to 1 second
remember_state: true
# Remember current light state
```

+ Audio In and Audio Out for Rhasspy
```
Rhasspy uses ALSA to play and record audio. That’s why we need to tell ALSA to use a virtual PulseAudio device. This is quite easy.

Open "/etc/asound.conf" and insert the following content:

pcm.!default {
    type pulse
    # If defaults.namehint.showall is set to off in alsa.conf, then this is
    # necessary to make this pcm show up in the list returned by
    # snd_device_name_hint or aplay -L
    hint.description "Default Audio Device"
}
ctl.!default {
    type pulse
}

"type pulse" requires some extra libraries that can be installed with the following command:

$ sudo apt install libasound2-plugins

After that arecord and aplay should work just like their PulseAudio counterparts.
```
