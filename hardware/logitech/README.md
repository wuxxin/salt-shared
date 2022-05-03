# Logitech Gxxx Keyboards

## profile examples

pillar["logitech:g-keyboard:profile"]

### g810
```yaml
profile: |
  # Sample profile by g810
  a 000000
  g arrows 202020
  g fkeys 050505
  g functions 111111
  g indicators 202020
  g keys 090909
  g logo 000000
  g modifiers 202020
  g multimedia 202020
  g numeric 020202
  k print_screen 000000
  k scroll_lock 000000
  k pause_break 000000
  k win_right 000000
  c
```

### g815
```yaml
profile: |
  # Sample profile for g815
  a 000000
  g arrows 404040
  g fkeys 208040
  g functions 606060
  g gkeys 006060
  g indicators 406040
  g keys 808080
  g logo 000000
  g modifiers 802020
  g multimedia 802080
  g numeric 404040
  c
```

### examples

+ switch on logo indicator breathing
    `sudo g810-led -fx breathing logo 888888 0a`
+ switch off logo indicator
    `sudo g810-led -k logo 000000`
