# Transactional Email

+ postfix for inbound and outbound mail, SSL/TLS support and outbound rate limiting
+ opendkim for outbound dkim signing
+ Future, inbound:
  + delivery status report parsing and webhook triggering
  + rspamd integration

## Example Pillar

```yaml
email:
  domain: domain.top
  allowed_domains:
    - domain.top
    - localhost
```

## Delivery Status Report

### parse all currently available new DSR's of a users mailbox via a cronjob
```sh
/usr/local/bin/dsr-hook.sh --format sendgrid --post https://localhost:1234/webhook/sendgrid \
    --from-maildir /var/lib/mail/{{ settings.delivery_status_report.user }}
```

### parse DSR using a postfix custom transport
```jinja
transport_maps: |
  {{ settings.delivery_status_report.bounce_recipient }}@{{ settings.domain }} dsr_delivery_sendgrid
  {{ settings.delivery_status_report.delay_recipient }}@{{ settings.domain }} dsr_delivery_sendgrid
  {{ settings.delivery_status_report.error_recipient }}@{{ settings.domain }} dsr_delivery_sendgrid
master_cf: |
  dsr_delivery_sendgrid  unix -       n       n       -       -       pipe
      flags=FRq user={{ settings.delivery_status_report.user }}
      argv=/usr/local/bin/dsr-hook.sh --format zonemta --post https://127.0.0.1:8855/zone-mta
        --from-stdin --save-on-fail /var/mail/{{ settings.delivery_status_report.user }}
        --sender ${sender} --recipient ${recipient}
```

### parsing DSR reports using getmail reading mails from an imap account, saving unreadable/non dsr to maildir
```conf
# Filter and drop on successful webhook post, else write to maildir
[filter-1]
type = Filter_classifier
path = /usr/local/bin/dsr-hook.sh
arguments = ("--format", "sendgrid", "--post", "https://localhost:1234/webhook/sendgrid" , "--from-stdin")
exitcodes_drop = (0,)
[destination]
```

### DSR.Reason: one of
  "Blocked", "Content Error", "Delivered", "Exceed Limit", "Expired", "Feedback",
  "Filtered", "Has Moved", "Host Unknown", "Mailbox Full", "Mailer Error",
  "Mesg Too Big", "Network Error", "No Relaying", "Not Accept", "On Hold",
  "Rejected", "Security Error", "securityerr", "Spam Detected", "Suspend",
  "Syntax Error", "System Error", "System Full", "Too Many Conn", "Undefined",
  "User Unknown", "Vacation"

### sendgrid format

email= addresser
timestamp= timestamp or bounced
smtp-id= description/messageid
event: bounce, deferred, delivered, spamreport, unsubscribe
  fraudreport
sg_event_id =
sg_message_id = message_id

reason= reason

status= replycode SMTP reply code such as "550", "422".
type= bounce, blocked,

action  	"failed", "expired", "delivered"
softbounce value for checking whether it is soft bounce or not
