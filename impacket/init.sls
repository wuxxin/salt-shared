include:
  - subversion
  - python

impacket:
  pip.installed:
    - name: "svn+http://impacket.googlecode.com/svn/trunk/"
 {# "svn+http://impacket.googlecode.com/svn/tags/impacket_0_9_12/" #}
    - require:
      - pkg: subversion
      - pkg: python
