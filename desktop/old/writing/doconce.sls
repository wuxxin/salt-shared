include:
  - vcs
  - python
  - python.ipython
  - latex
  - desktop.writing.libreoffice

prereq_doconce:
  pkg.installed:
    - pkgs:
      - idle
      - python-pdftools
      - graphicsmagick-imagemagick-compat
      - netpbm
      - mjpegtools
      - pdftk
      - giftrans
      - gv
      - ffmpeg
      - ispell
      - pandoc
      - unoconv
      - libreoffice-dmaths
      - curl
      - a2ps
    - require:
      - sls: vcs
      - sls: python
      - sls: latex
      - sls: desktop.writing.libreoffice

{% load_yaml as pip_list %}
 - "sphinx"
 - "mako"
 - "svn+http://preprocess.googlecode.com/svn/trunk#egg=preprocess"
 - "hg+https://bitbucket.org/logg/publish#egg=publish"
 - "hg+https://bitbucket.org/ecollins/cloud_sptheme#egg=cloud_sptheme"
 - "git+https://github.com/ryan-roemer/sphinx-bootstrap-theme#egg=sphinx-bootstrap-theme"
 - "hg+https://bitbucket.org/miiton/sphinxjp.themes.solarized#egg=sphinxjp.themes.solarized"
 - "git+https://github.com/shkumagai/sphinxjp.themes.impressjs#egg=sphinxjp.themes.impressjs"
 - "git+https://github.com/kriskda/sphinx-sagecell#egg=sphinx-sagecell"
 - "svn+https://epydoc.svn.sourceforge.net/svnroot/epydoc/trunk/epydoc#egg=epydoc"
 - "git+https://github.com/hplgit/doconce.git"
 - "svn+https://ptex2tex.googlecode.com/svn/trunk/"
{% endload %}

{% for p in pip_list %}
"{{ p }}_install":
  pip:
    - installed
    - name: "{{ p }}"
    - require:
      - sls: python
    - require_in:
      - cmd: doconce
{% endfor %}

doconce:
  cmd.run:
    - name: "which doconce"
    - require:
      - pkg: prereq_doconce

{#
# Ptex2tex
cd srclib
svn checkout http://ptex2tex.googlecode.com/svn/trunk/ ptex2tex
cd ptex2tex
sudo python setup.py install -y
cd latex
sh cp2texmf.sh  # copy stylefiles to ~/texmf directory
cd ../../..
#}
