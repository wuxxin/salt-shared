include:
  - vcs
  - python
  - desktop.writing.latex
  - desktop.language.spellcheck

pipx_install('sphinx')
pipx_inject('sphinx', ['sphinxcontrib.actdiag', 'sphinxcontrib.blockdiag',
  'sphinxcontrib.nwdiag', 'sphinxcontrib.seqdiag', 'sphinxcontrib.spelling'])


sphinx:
  pkg.installed:
    - pkgs:
      - zip
      - python3-sphinx
      - python3-sphinxcontrib.actdiag
      - python3-sphinxcontrib.blockdiag
      - python3-sphinxcontrib.nwdiag
      - python3-sphinxcontrib.seqdiag
      - python3-sphinxcontrib.spelling
      - python3-pil
