# Unbound Caching Recursive Resolver

```yaml
unbound:
  enabled: true
  verbosity: 3
  listen:
    - 127.0.0.1
  answer:
    - 127.0.0.1/8
  authorative:
    unsigned:
      "local": "127.0.1.1"
      "0.0.127.in.addr.arpa": "127.0.1.1"
```
