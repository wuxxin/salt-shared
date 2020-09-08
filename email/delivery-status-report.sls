
{#
set postfix to use VERP,
and use library to parse bounce messages
https://gitlab.com/warsaw/flufl.bounce
https://libsisimai.org/en/

reader:
  user: dsr_reader
  cmd: /usr/local/bin/dsr2webhook.sh
  args: --format sendgrid --url https://127.0.0.1:8855/webhook/sendgrid

dsr_transports:
  - name: dsr2hook_sendgrid
    user: postbounce
    cmd: /usr/local/bin/dsr2webhook --format sendgrid --hook https://127.0.0.1:8855/sendgrid/ --sender ${sender} --recipient ${recipient}

  - name: dsr2hook_zonemta
    user: postbounce
    cmd: /usr/local/bin/dsr2webhook --format zone-mta --hook https://127.0.0.1:8855/zone-mta/ --sender ${sender} --recipient ${recipient}

transport_maps: |
    {{ settings.delivery_status.recipient }} dsr2hook_{{ settings.delivery_status.type }}

master_cf: |
    dsr2hook_{{ settings.delivery_status.type }} unix -       n       n       -       -       pipe
    flags=FRq user={{ settings.delivery_status.user }} argv=/usr/local/bin/dsr2webhook --sender ${sender} --recipient ${recipient} --hook-format zonemta https://127.0.0.1:8855/zone-mta/

#}
