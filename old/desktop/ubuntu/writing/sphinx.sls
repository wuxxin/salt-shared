{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - vcs
  - code.python
  - desktop.ubuntu.writing.latex
  - desktop.ubuntu.language.spellcheck

sphinx-req:
  pkg.installed:
    - pkgs:
      - zip
    - require:
      - sls: vcs
      - sls: python
      - sls: desktop.ubuntu.writing.latex
      - sls: desktop.ubuntu.language.spellcheck

{{ pipx_install('sphinx', require='test: sphinx-req', user=user) }}
{{ pipx_inject('sphinx', ['sphinxcontrib.actdiag', 'sphinxcontrib.blockdiag',
  'sphinxcontrib.nwdiag', 'sphinxcontrib.seqdiag', 'sphinxcontrib.spelling'], user=user)
