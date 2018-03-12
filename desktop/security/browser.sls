torbrowser-launcher:
  pkg:
    - installed

{# if running tor-browser fails, run as user 

update-tor-keys:
  cmd.run:
    - name: gpg --homedir "$HOME/.local/share/torbrowser/gnupg_homedir/" --refresh-keys --keyserver pool.sks-keyservers.net
    
#}
