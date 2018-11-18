forensic-packages:
  pkg.installed:
    - pkgs:
      {# forensic #}
      - ext4magic   {# disk utility to recover files from ext3 or ext4 partitions #}
      - volatility  {# advanced memory forensics framework #}
      {# - cabextract      {# extract MS cab files #}
      {# - pff-tools       {# export PAB,PST and OST files (MS Outlook) #}

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip3_install('msoffcrypto-tool') }} {# Python tool and library for decrypting encrypted MS Office files #}
