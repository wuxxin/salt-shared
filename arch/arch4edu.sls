import-arch4edu-keyring:
  file.managed:
    - source: https://mirrors.tuna.tsinghua.edu.cn/arch4edu/any/arch4edu-keyring-20200805-1-any.pkg.tar.zst
    - source_hash: a6abbb16e57bb9065689f5b5391c945e35e256f2e6dbfa11476fdfe880f72775
    - name: /etc/pacman.d/arch4edu-keyring-20200805-1-any.pkg.tar.zst
  cmd.run:
    - name: pacman -U /etc/pacman.d/arch4edu-keyring-20200805-1-any.pkg.tar.zst
    - onchange:
      - file: import-arch4edu-keyring

enable-arch4edu:
  file.serialize:
    - name: /etc/pacman.conf
    - dataset: 
        arch4edu:
          Server: https://pkg.fef.moe/arch4edu/$arch
    - formatter: toml
    - merge_if_exists: True
  