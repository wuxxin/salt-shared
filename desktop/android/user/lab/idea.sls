include:
  - desktop.idea

{% from "desktop/idea/lib.sls" import idea-plugin with context %}
{% from "desktop/user/lib.sls import user with context %}

# {{ idea-plugin(user,'adt_tools', 'https://dl-ssl.google.com/android/eclipse/', 
#    'com.android.ide.eclipse.adt.feature.group,com.android.ide.eclipse.ndk.feature.group') }}
