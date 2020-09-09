#!/usr/bin/env python3

import sys
import json

dsr = json.load(sys.stdin)

sendgrid = {
    "email": dsr.email,
    "timestamp": dsr.timestamp,
    "stmp-id": dsr.messageid,
    "event": dsr.event,
    "reason": dsr.reason,
    "status": dsr.status,
    "type": dsr.type,
    "sg_event_id": "whatever",
    "sg_message_id": dsr.message_id,
}

json.dump(sendgrid, sys.stdout, sort_keys=True)
