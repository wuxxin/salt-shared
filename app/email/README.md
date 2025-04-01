# Transactional Email

+ postfix for inbound and outbound mail, SSL/TLS support and rate limiting
+ optional
  + outbound dkim signing using opendkim
  + inbound delivery status report parsing and webhook triggering
  + rspamd filtering

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
/usr/local/bin/dsr-delivery.sh --format sendgrid --post https://localhost:1234/webhook/sendgrid \
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
      argv=/usr/local/bin/dsr-delivery.sh --format sendgrid --post https://127.0.0.1:8855/sendgrid
        --from-stdin --save-on-fail /var/mail/{{ settings.delivery_status_report.user }}
        --sender ${sender} --recipient ${recipient}
```

### parsing DSR reports using getmail reading mails from an imap account,
```conf
# Filter and drop on successful webhook post, else saving unreadable/non dsr to maildir
[filter-1]
type = Filter_classifier
path = /usr/local/bin/dsr-delivery.sh
arguments = ("--format", "sendgrid", "--post", "https://localhost:1234/webhook/sendgrid" , "--from-stdin")
exitcodes_drop = (0,)
[destination]
```

### sisimai

Action (String)
action  	"failed", "expired", "delivered": softbounce value for checking whether it is soft bounce or not
Addresser (Sisimai::Address)
  "addressser" is a Sisimai::Address object generated from the sender address. When Sisimai::Data object is dumped as JSON, this value converted to an email address. Sisimai::Address object has the following accessors:
    user() - The local part of the address
    host() - The domain part of the address
    address() - Email address
    verp() - Variable envelope return path
    alias() - Alias of the address
    name() - Display name (v4.22.1 or later)
    comment() - Comment (v4.22.1 or later)
alias (String)
deliverystatus (String)
destination (String)
diagnosticcode (String)
diagnostictype (String)
feedbacktype (String) "feedbacktype" is the value of Feedback-Type: field like "abuse", "fraud", "opt-out" in a bounce message. When the message is not ARF format or the value of "reason" is not "feedback", this value will be empty.
lhost (String)
listid (String)
messageid (String)
origin (String)
reason (String) one of
  "Blocked", "Content Error", "Delivered", "Exceed Limit", "Expired", "Feedback",
  "Filtered", "Has Moved", "Host Unknown", "Mailbox Full", "Mailer Error",
  "Mesg Too Big", "Network Error", "No Relaying", "Not Accept", "On Hold",
  "Rejected", "Security Error", "securityerr", "Spam Detected", "Suspend",
  "Syntax Error", "System Error", "System Full", "Too Many Conn", "Undefined",
  "User Unknown", "Vacation"
recipient (Sisimai::Address)
replycode (String)
rhost (String)
senderdomain (String)
smtpagent (String)
smtpcommand
softbounce (Integer)
    1 = Soft bounce
    0 = Hard bounce
    -1 = Sisimai could not decide
subject (String)
timestamp (Sisimai::Time)
timezoneoffset (String)
token (String)
