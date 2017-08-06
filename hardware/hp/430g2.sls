
# for uefi boot see http://askubuntu.com/questions/554690/hp-uefi-doesnt-boot-ubuntu-automatically

# hp probook 430 g2 fixes for ubuntu 14.04

# if salt['cmd.run_stdout']('which systool') != "" 

/etc/modprobe.d/rtl8723be.conf:
  file.managed:
    - contents: |
        options rtl8723be ips=0
        options rtl8723be fwlps=0
