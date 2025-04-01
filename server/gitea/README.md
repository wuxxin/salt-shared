# gitea

## to define a gitea instance, set pillar

```yaml
gitea:
  profile:
    - name: profilename
      global:
        # all global app.ini entries, all keys are lowercase
      gpg:
        key: optional, gpg secret key (ascii armored) to be activated for gitea
      server:
        domain: full.qualified.domain.name
        root_url: may be needed to set, eg. if behind reverse proxy eg. %(PROTOCOL)s://%(DOMAIN)s:%(HTTP_PORT)s/
        lfs_jwt_secret: optional, but mandatory if enabling lfs, eg. "openssl rand -base64 32"
      security:
        secret_key: mandatory, eg. "openssl rand -base64 32"
      oauth2:
        # enable: default "true"
        jwt_secret: mandatory if oauth2:enable:true , eg. "openssl rand -base64 32"
      session:
        cookie_secure: "true" if access to gitea is only accessed via https
      any_section_from_app_ini:
          # app.ini sections, all keys are lowercase
```

### for each profile

+ the profile_defaults will be merged with the defined profile
+ global:run_user if not defined will be set to gitea_<profile:name>
+ salt:home_dir (home of run_user) if not defined will be set to /home/'+ global.run_user
+ repository:root if not defined will be set to ~/repos
+ GITEA_WORK_DIR will be set to salt:work_dir (defaults to ~/work)
+ GITEA_CUSTOM will be set to salt:custom_dir (defaults to ~/custom)
+ oauth2:enable will be set to false if oauth2:jwt_secret is not set
+ server:lfs_start_server will be set to false if server:lfs_jwt_secret is not set
+ server:http_addr if not defined and
  + server:protocol == unix, it will be set to /run/gitea_<profile:name>/gitea.sock
  + server:protocol == http, it will be set to 127.0.0.1

## tools

+ cli: https://gitea.com/gitea/tea
