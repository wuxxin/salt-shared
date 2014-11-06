include:
  - git 

{% set examples=[
'saltstack/salt-states', 
'saltstack/salt-contrib', 
'esacteksab/salt-states', 
'uggedal/states', 
'brutasse/states', 
'bclermont/states', 
'esacteksab/salt-states',
'oc/roninku',
'saltops/saltmine',
'blast-hardcheese/blast-salt-states',
'jaddison/vagrant-salt-demo',
'jaddison/salt-base-states',
'daviddyball/salt'
] %}

{% for x in examples %}
example_{{ x }}:
  git.latest:
    - name: https://github.com/{{ x }}.git
    - target: /root/salt-examples/{{ x }}
    - submodules: True
    - require:
      - pkg: git
{% endfor %}
