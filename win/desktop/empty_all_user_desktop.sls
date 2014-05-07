empty_all_user_desktop_links:
  cmd.run:
    - name: del /F "%PUBLIC%\Desktop\*.lnk"
