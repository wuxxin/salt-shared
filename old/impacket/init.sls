include:
  - python
  - vcs.subversion

python-pyasn1:
  pkg:
    - installed

impacket:
  pip.installed:
    - name: "svn+http://impacket.googlecode.com/svn/trunk/"
    - require:
      - sls: python
      - sls: vcs.subversion
      - pkg: python-pyasn1
