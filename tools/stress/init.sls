
stress-tools:
  pkg.installed:
    - pkgs:
      - fio       {# flexible I/O tester #}
      - iperf3    {# network throughput measurements. It can test either TCP or UDP throughput #}
      - netstress {# client/server utility designed to stress and benchmark network activity #}
      - stressant {# stressant is testing various parts of the system (CPU, RAM, disk, network) #}
      - stress-ng {# stress load CPU, cache, disk, memory, socket and pipe I/O, scheduling #}

{#      
      - tsung      a distributed load testing tool to stress HTTP, WebDAV, SOAP, PostgreSQL, MySQL, LDAP, Jabber/XMPP 
#}
