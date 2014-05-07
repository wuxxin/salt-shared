include:
  - roles.desktop.eclipse

{% from "roles/desktop/eclipse/lib.sls" import eclipse-plugin with context %}
{% from "roles/desktop/user/lib.sls import user with context %}

{{ eclipse-plugin(user,'adt_tools', 'https://dl-ssl.google.com/android/eclipse/', 
    'com.android.ide.eclipse.adt.feature.group,com.android.ide.eclipse.ndk.feature.group') }}

