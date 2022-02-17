forensic-packages:
  pkg.installed:
    - pkgs:
      {# forensic #}
      - ext4magic   {# disk utility to recover files from ext3/4 partitions #}
      - cabextract  {# extract MS cab files #}
      - pff-tools   {# export PAB,PST and OST files (MS Outlook) #}
      - mmdb-bin    {# IP geolocation lookup command-line tool #}
      - fcrackzip   {# password cracker for zip archives #}

{# - volatility  advanced memory forensics framework #}
{% from 'python/lib.sls' import pip_install %}
{{ pip_install('msoffcrypto-tool') }} {# decrypting encrypted MS Office files #}

auditing-packages:
  pkg.installed:
    - pkgs:
      {# auditing #}
      - nikto       {# web server,CGI scanner to perform security checks #}
      - wapiti      {# audit the security of your web applications #}
      - nmap        {# utility for network exploration or security auditing #}
