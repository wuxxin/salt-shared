include:
  - subversion
  - python

python-pyasn1:
  pkg:
    - installed

impacket:
  pip.installed:
    - name: "svn+http://impacket.googlecode.com/svn/trunk/"
 {# "svn+http://impacket.googlecode.com/svn/tags/impacket_0_9_12/" #}
    - require:
      - pkg: subversion
      - sls: python
      - pkg: python-pyasn1
