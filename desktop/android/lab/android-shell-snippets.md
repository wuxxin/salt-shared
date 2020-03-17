# Android Shell Snippets

+ change which radios are disabled in airplane mode:
  + get list of disabled radios in airplane mode:
      + `settings get global airplane_mode_radios`
      + returns: `cell,bluetooth,wifi,nfc,wimax`
     
  + set list of disabled radios in airplane mode
      + `settings put global airplane_mode_radios cell`
     
+ get IMEI: `adb shell "service call iphonesubinfo 1 | toybox cut -d \"'\" -f2 | toybox grep -Eo '[0-9]' | toybox xargs | toybox sed 's/\ //g'"`
    + or: `adb shell service call iphonesubinfo 1 | awk -F "'" '{print $2}' | sed '1 d' | tr -d '.' | awk '{print}' ORS=`
+ List installed packages: `cmd package list package`
  + only third party: `cmd package list package -3`
+ list users: `dumpsys user` or `pm list users`
+ find default activity: `cmd package resolve-activity --brief org.fdroid.fdroid`
+ services: 
  + list detailed `dumpsys activity services`
  + list verbatim `service list`
  + service entry points `get_android_service_call_numbers.sh servicename`
  + service call `service call SERVICE CODE [i32 N | i64 N | f N | d N | s16 STR ]`
    Options:
      i32: Write the 32-bit integer N into the send parcel.
      i64: Write the 64-bit integer N into the send parcel.
      f:   Write the 32-bit single-precision number N into the send parcel.
      d:   Write the 64-bit double-precision number N into the send parcel.
      s16: Write the UTF-16 string STR into the send parcel.
+ list resolve table of package
  + `dumpsys package de.j4velin.pedometer`
+ content providers
  + list `adb shell dumpsys | grep -a "Provider{"` https://stackoverflow.com/questions/27988069/query-android-content-provider-from-command-line-adb-shell/27993247

+ Snippets: https://gist.github.com/Pulimet/5013acf2cd5b28e55036c82c91bd56d8

+ Permanent Disable of RIL (Cellular Data)

  + https://android.stackexchange.com/questions/155261/is-it-possible-to-completely-disable-radio-signal-in-a-phone-without-a-sim-card

  + Disabling RIL
    If the operation is not to be performed frequently, a single line of code will be all that is needed: `su -c "setprop persist.radio.noril 1"`

    This will make the phone ignore the Radio Interface Layer, thus ignoring the presence of the antenna. A reboot is required for the change to be in effect, and it will persist across reboots. Plus, disabling RIL also makes the "No SIM Card icon vanish.

  + Enabling RIL
    Enabling RIL again is just a matter of flags. As can be seen from the below example:
    `su -c "setprop persist.radio.noril 0"`

    the command is equivalent, save for a 0 instead of a 1. As before, a reboot is needed.

+ Default Content Provider:
    + https://developer.android.com/reference/android/provider/package-summary
    + The following content providers are provided by default:
```
    content://browser/bookmarks
    content://browser/searches
    content://call_log/calls
    content://com.android.calendar/attendees
    content://com.android.calendar/calendar_alerts
    content://com.android.calendar/calendars
    content://com.android.calendar/event_entities
    content://com.android.calendar/events
    content://com.android.calendar/reminders
    content://com.android.contacts/aggregation_exceptions
    content://com.android.contacts/contacts
    content://com.android.contacts/data
    content://com.android.contacts/groups
    content://com.android.contacts/raw_contact_entities
    content://com.android.contacts/raw_contacts
    content://com.android.contacts/settings
    content://com.android.contacts/status_updates
    content://com.android.contacts/syncstate
    content://drm/audio
    content://drm/images
    content://icc/adn
    content://icc/fdn
    content://icc/sdn
    content://media/external/audio/albums
    content://media/external/audio/artists
    content://media/external/audio/genres
    content://media/external/audio/media
    content://media/external/audio/playlists
    content://media/external/images/media
    content://media/external/images/thumbnails
    content://media/external/video/media
    content://media/external/video/thumbnails
    content://media/internal/audio/albums
    content://media/internal/audio/artists
    content://media/internal/audio/genres
    content://media/internal/audio/media
    content://media/internal/audio/playlists
    content://media/internal/images/media
    content://media/internal/images/thumbnails
    content://media/internal/video/media
    content://media/internal/video/thumbnails
    content://mms
    content://mms/inbox
    content://mms/outbox
    content://mms/part
    content://mms/sent
    content://mms-sms/conversations
    content://mms-sms/draft
    content://mms-sms/locked
    content://mms-sms/search
    content://settings/secure
    content://settings/system
    content://sms/conversations
    content://sms/draft
    content://sms/inbox
    content://sms/outbox
    content://sms/sent
    content://telephony/carriers
    content://user_dictionary/words
```
