
fake-background-webcam:
  git.latest:
    - source: https://github.com/wuxxin/Linux-Fake-Background-Webcam.git
    - name: /usr/local/lib/fake-background-webcam


version: '3'
services:
  bodypix:
    image: bodypix
    build:
      context: ./bodypix
  fakecam:
    image: fakecam
    build:
        context: ./fakecam
    #volumes:
    #  - /home/pczarkowski/Pictures/bg.jpg:/src/background.jpg:ro
    #   - /path/to/foreground.jpg:/src/foreground.jpg:ro
    #   - /path/to/foreground-mask.png:/src/foreground-mask.png:ro
    devices:
      - /dev/video1:/dev/video0
      - /dev/video7:/dev/video2
    depends_on:
      - bodypix
    entrypoint:
      - python3
      - -u
      - fake.py
      - -B
      - 'http://bodypix:9000/'
      - --no-foreground
