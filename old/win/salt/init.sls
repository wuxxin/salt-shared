salt:
  pkg:
    - latest

# On windows server 2003, you need to install optional windows component "wmi windows installer provider" 
# to have full list of installed packages. If you don't have this, salt-minion can't report some installed software.
