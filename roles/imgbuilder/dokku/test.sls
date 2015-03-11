{% from "roles/imgbuilder/dokku/lib.sls" import create_container with context %}

{{ create_container("openproject", "roles/imgbuilder/templates/dokku/openproject/dokku.yml") }}
