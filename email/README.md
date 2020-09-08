# Transactional Email

+ postfix for inbound and outbound mail with SSL/TLS support
+ opendkim for outbound dkim signing
+ outbound ratelimiting via postfix
+ Future, inbound:
  + delivery status report parsing (transform to sendgrid like webhook)
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

### Reason= one of:
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
