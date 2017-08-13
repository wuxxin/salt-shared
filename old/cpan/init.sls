{% from 'cpan/lib.sls' import cpan_install with context %}

{{ cpan_install('Inline::Python') }}
