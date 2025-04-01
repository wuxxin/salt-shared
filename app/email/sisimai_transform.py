#!/usr/bin/env python3

import sys
import json

dsr = json.load(sys.stdin)

sendgrid_example = {
    "email": "example@test.com",
    "timestamp": 1513299569,
    "smtp-id": "<14c5d75ce93.dfd.64b469@ismtpd-555>",
    "event": "dropped",
    "category": "cat facts",
    "sg_event_id": "zmzJhfJgAfUSOW80yEbPyw==",
    "sg_message_id": "14c5d75ce93.dfd.64b469.filter0001.16648.5515E0B88.0",
    "reason": "Bounced Address",
    "status": "5.0.0"
}

sendgrid = {
    "email": dsr.addresser,
    "timestamp": dsr.timestamp,
    "stmp-id": dsr.messageid,
    "event": "bounce, deferred, dropped, delivered, spamreport, unsubscribe",
    "category": "cat facts",
    "sg_event_id": dsr.token,
    "sg_message_id": dsr.messageid,
    "reason": dsr.reason,
    "status": dsr.status,
    "type": "bounce, blocked: only if event: bounce",
}

json.dump(sendgrid, sys.stdout, sort_keys=True)
