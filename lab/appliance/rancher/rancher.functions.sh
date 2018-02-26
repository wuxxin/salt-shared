# wait for server
# first, find the default environment id
env = get_default_environment(endpoint)
# second, create a new api key in the environment
api_key = create_api_key(env)
# then create an admin api key (only to modify the admin user settings)
admin_api_key = create_admin_api_key(endpoint)
#now use this api token for all further processing on this chef node
node.set['rancher']['automation_api_key'] = api_key['publicValue']
node.set['rancher']['automation_api_secret'] = api_key['secretValue']
#create the localAuthConfig request
enable_local_auth(endpoint, admin_api_key)
#set the admin user preferences (default login environment)
set_admin_user_preferences(endpoint, admin_api_key)
node.set['rancher']['flag']['authenticated'] = true
new_resource.updated_by_last_action(true)

+ wait for server
if [ "$(curl -s http://${server_ip}:8080/ping)" = "pong" ]; then

+ enable localAuthConfig
```
"accessMode": "unrestricted",
"enabled": true,
"name": "admin",
"password": "{{ settings.auth.password }}",
"username": "{{ settings.auth.username }}",
```

+ get access token
```
POST /v2-beta/token {code: "{{ settings.auth.username }}:{{ settings.auth.password }}"}
```

+ get agent registration token
```
# v3 cluster
GET /v3/clusters | python -c 'import json,sys; print(json.load(sys.stdin)["data"][0]["registrationToken"]["hostCommand"])'
# v2 cluster
# get first project id
project_id= GET /v2-beta/projects | python -c'import json,sys;print(json.load(sys.stdin)["data"][0]["id"])')
regtokenlink= POST /v2-beta/projects/${project_id}/registrationtokens|python -c'import json,sys; print(json.load(sys.stdin)["links"]["self"])')
sleep 2
GET $reg_tokens_link|python -c'import json,sys; print(json.load(sys.stdin)["command"])')
```

https://github.com/rancher/10acre-ranch/blob/master/bin/mac-ranch

get_registration_cmd()
  if [ -z "${cmd}" ]; then
    # v3 cluster
    cmd=$(curl -s http://${server_ip}:8080/v3/clusters | python -c 'import json,sys; print(json.load(sys.stdin)["data"][0]["registrationToken"]["hostCommand"])')
  fi
  if [ -z "${cmd}" ]; then
    # v2 registrationToken
    local project_id
    local link
    project_id=$(curl -s http://${server_ip}:8080/v2-beta/projects|python -c'import json,sys;print(json.load(sys.stdin)["data"][0]["id"])')
    reg_tokens_link=$(curl -s -X POST http://${server_ip}:8080/v2-beta/projects/${project_id}/registrationtokens|python -c'import json,sys; print(json.load(sys.stdin)["links"]["self"])')
    sleep 2
    cmd=$(curl -s $reg_tokens_link|python -c'import json,sys; print(json.load(sys.stdin)["command"])')
  fi
  cmd=$(echo $cmd | sed "s/docker run/docker run -e CATTLE_AGENT_IP=\"${ip_cmd}\"/")
wait_for_server()
  if [ "$(curl -s http://${server_ip}:8080/ping)" = "pong" ]; then
register_hosts()
  

build_cluster()
{
  local offset

  if [ -z "${REGISTRATION_CMD}" ]; then
    build_master
  fi

  offset=$(build_hosts)
  wait_for_server
  register_hosts $offset

  server_ip=$(get_server_ip)
  echo "Connect to rancher-server at http://${server_ip}:8080/"
  echo ""
}


https://github.com/mediadepot/chef-docker_rancher/blob/master/libraries/provider_auth_local.rb#L70-L109

endpoint = "http://#{new_resource.manager_ipaddress}"
endpoint += ":#{new_resource.manager_port}" if new_resource.manager_port
# first, find the default environment id
env = get_default_environment(endpoint)
# second, create a new api key in the environment
api_key = create_api_key(env)
# then create an admin api key (only to modify the admin user settings)
admin_api_key = create_admin_api_key(endpoint)

#now use this api token for all further processing on this chef node
node.set['rancher']['automation_api_key'] = api_key['publicValue']
node.set['rancher']['automation_api_secret'] = api_key['secretValue']

#create the localAuthConfig request
enable_local_auth(endpoint, admin_api_key)

#set the admin user preferences (default login environment)
set_admin_user_preferences(endpoint, admin_api_key)

node.set['rancher']['flag']['authenticated'] = true
new_resource.updated_by_last_action(true)



# wait for rancher server api
curl -s --connect-timeout 1 http://{{ settings.ip }}:{{ settings.port }}/v2-beta
result=$?
while ! $result; do
    wget --retry-connrefused --tries=30 -q --spider \
        http://{{ settings.ip }}:{{ settings.port }}/v2-beta
    result=$?
    sleep 10
done

# create environments if not existing
for e in {{ settings.environments }}; do
    rancher_env_id = salt['cmd.run']('curl -s "http://' + settings.ip + ':' + settings.port|string + '/v2-beta/projectTemplates?name=' + e + '" | jq ".data[0].id"') %}
  
    curl -s 'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects' \
        | jq .data[].name | grep -w '{{ rancher_env_name }}'
    result=$?
    if ! $result; then
        curl -s \
            -X POST \
            -H 'Accept: application/json' \
            -H 'Content-Type: application/json' \
            -d '{"name":"{{ rancher_env_name }}", "projectTemplateId":{{ rancher_env_id }}, "allowSystemRole":false, "members":[], "virtualMachine":false, "servicesPortRange":null}' \
            'http://{{ rancher_ip }}:{{ rancher_port }}/v2-beta/projects'
    fi
done

# wait for rancher agent api
curl -s --connect-timeout 1 http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }}/v1
result=$?
if ! $result; then
    wget --retry-connrefused --tries=30 -q --spider \
        http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }}/v1
fi

# rancher-agent-registration
docker inspect rancher-agent
result=$?
if ! $result; then 
    rancher-agent-registration \
        --url http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }} \
        --key KEY --secret SECRET --environment {{ settings.environment }}

  
rancher-server-api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ rancher.server.ip }}:{{ rancher.server.port }}/v2-beta && sleep 10
    - unless: curl -s --connect-timeout 1 http://{{ rancher.server.ip }}:{{ rancher.server.port }}/v2-beta
    - require:
      - dockerng: rancher-server-container


{% set settings.environments = salt['pillar.get']('rancher:server:environments') %}

{% if settings.environments %}
{% for env in rancher_environments %}
{% set rancher_env_name = salt['pillar.get']('rancher:server:environments:' + env + ':name') %}
{% set rancher_env_id = salt['cmd.run']('curl -s "http://' + rancher_ip + ':' + rancher_port|string + '/v2-beta/projectTemplates?name=' + rancher_env_name + '" | jq ".data[0].id"') %}
add_{{ env }}_environment:
  cmd.run:
    - name: |
        curl -s \
             -X POST \
             -H 'Accept: application/json' \
             -H 'Content-Type: application/json' \
             -d '{"name":"{{ rancher_env_name }}", "projectTemplateId":{{ rancher_env_id }}, "allowSystemRole":false, "members":[], "virtualMachine":false, "servicesPortRange":null}' \
             'http://{{ rancher_ip }}:{{ rancher_port }}/v2-beta/projects'
    - unless: |
        curl -s 'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects' \
             | jq .data[].name \
             | grep -w '{{ rancher_env_name }}'
{% endfor %}
{% endif %}

rancher-agent-api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }}/v1
    - unless: curl -s --connect-timeout 1 http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }}/v1
    - require:
      - sls: .server

rancher-agent-container:
  cmd.run:
    - name: |
        rancher-agent-registration --url http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }} \
        --key KEY --secret SECRET --environment {{ settings.environment }}
    - unless: docker inspect rancher-agent
    - require:
      - cmd: rancher_server_api_wait
      - pip: agent_registration_module

    - name: rancher-agent
    - image: rancher/agent:{{ rancher.agent_tag }}
    - binds:
      - /data/mysql/rancher-server:/var/lib/mysql
    - port_bindings:
      - {{ rahcner.server.ip }}:{{ rancher.server.port }}:8080
    - restart_policy: always
    - require:
      - dockerng: rancher-agent-image
