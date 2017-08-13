include:
  - python

python-pyasn1:
  pkg:
    - installed

subversion:
  pkg:
    - installed

impacket:
  pip.installed:
    - name: "svn+http://impacket.googlecode.com/svn/trunk/"
    - require:
      - pkg: subversion
      - sls: python
      - pkg: python-pyasn1
