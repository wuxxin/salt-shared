{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install, pipx_inject %}

include:
  - python.dev

{# python code formating/linting/auditing tools #}
python-tools:
  pkg.installed:
    - pkgs:
      - isort             {# sort imports separated into sections #}
      - mypy              {# type check type annotations #}
      - yapf3             {# code audit and reformating #}
      - pylama            {# code audit and reformating for Python #}
      - python3-autopep8  {# autopep8 - code audit and reformating to PEP 8 style #}

{# install the following as pipx user package, so they are isolated from others #}

{# cookiecutter - creates projects from cookiecutters (project templates) #}
{{ pipx_install('cookiecutter', user=user) }}

{# black - opinionated python source code formating #}
{{ pipx_install('black', user=user) }}

{# poetry - Python packaging and dependency management made easy #}
{{ pipx_install('poetry', user=user) }}

{# pipenv - Python Dev Workflow for Humans #}
{{ pipx_install('pipenv', user=user) }}

{# python language server plus extensions
{{ pipx_install('python-lsp-server[all]', user=user) }}
{{ pipx_inject('python-lsp-server[all]', [
  'pyls-isort', 'python-lsp-black', 'pyls-memestra', 'mypy-ls', 'pyls-flake8',
  ], user=user) }}
#}
