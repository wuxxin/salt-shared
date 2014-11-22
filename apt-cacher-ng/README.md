TODO:
client config

Specify the caching machine as HTTP Proxy for APT, e.g. putting a line like the following into a file like /etc/apt/apt.conf.d/02proxy:

Acquire::http { Proxy "http://CacheServerIp:3142"; };

