{#
https://gitlab.com/Teuniz/EDFbrowser/

apt install g++ make git-core qtbase5-dev-tools qtbase5-dev qt5-default
qmake
make -j16
sudo make install

Gist to save a mne.io.Raw object to an EDF file using pyEDFlib
(https://github.com/holgern/pyedflib)

https://gist.github.com/skjerns/bc660ef59dca0dbd53f00ed38c42f6be/812cd1d4be24c0730db449ecc6eb0065da68ca51

#}

edfbrowser:
  pkg.installed:
    - pkgs:
      - g++ 
      - make
      - git-core
      - qtbase5-dev-tools
      - qtbase5-dev
      - qt5-default
  git.latest:
    - name: https://gitlab.com/Teuniz/EDFbrowser.git
    - target: /usr/local/src/edfbrowser
    - require:
      - pkg: edfbrowser
  cmd.run:
    - name: qmake && make -j16
    - cwd: /usr/local/src/edfbrowser
  
  
