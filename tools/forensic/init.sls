forensic-packages:
  pkg.installed:
    - pkgs:
      {# forensic #}
      - ext4magic   {# disk utility to recover files from ext3/4 partitions #}
      - nikto       {# web server,CGI scanner to perform security checks #}
      - wapiti      {# audit the security of your web applications #}
      - nmap        {# utility for network exploration or security auditing #}
      - cabextract  {# extract MS cab files #}
      - pff-tools   {# export PAB,PST and OST files (MS Outlook) #}

{# - volatility  advanced memory forensics framework #}

{% from 'python/lib.sls' import pip3_install %}
{{ pip3_install('msoffcrypto-tool') }} {# decrypting encrypted MS Office files #}
