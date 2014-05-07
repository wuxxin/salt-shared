{% set memory=512m %}
{% set disk0={"15g","/dev/sda2","/dev/vg0/root" %}

{% for c in ["vm-halt", "vm-detach", "vm-move-network", "vm-update-dns", "vm-copy-resize", "vm-saltify" %}
{{ c }}("ttrss")

{% endfor %}
   