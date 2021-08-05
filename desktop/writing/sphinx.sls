{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - vcs
  - python
  - desktop.writing.latex
  - desktop.language.spellcheck

sphinx-req:
  pkg.installed:
    - pkgs:
      - zip
    - require:
      - sls: vcs
      - sls: python
      - sls: desktop.writing.latex
      - sls: desktop.language.spellcheck

{{ pipx_install('sphinx', require='test: sphinx-req', user=user) }}
{{ pipx_inject('sphinx', ['sphinxcontrib.actdiag', 'sphinxcontrib.blockdiag',
  'sphinxcontrib.nwdiag', 'sphinxcontrib.seqdiag', 'sphinxcontrib.spelling'], user=user)
