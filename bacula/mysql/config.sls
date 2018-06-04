{%- from "bacula/map.jinja" import map with context -%}

{% set dbhost = map.director.config.catalog.get('DB Address', 'localhost') | replace('"', '') %}
{% set dbname = map.director.config.catalog.get('DBName', 'bacula') | replace('"', '') %}
{% set dbuser = map.director.config.catalog.get('DBUser', 'bacula-dir') | replace('"', '') %}
{% set dbpass = map.director.config.catalog.get('DBPassword', 'password') | replace('"', '') %}

{% set dbroot_user = map.director.get('dbroot_user') %}
{% set dbroot_pass = map.director.get('dbroot_pass') %}

include:
  - mysql.server

bacula_db:
  mysql_database.present:
    - name: {{ dbname }}
    - host: {{ dbhost }}
    {%- if dbroot_user and dbroot_pass %}
    - connection_host: {{ dbhost }}
    - connection_user: {{ dbroot_user }}
    - connection_pass: {{ dbroot_pass }}
    {%- endif %}
    - character_set: utf8
    - collate: utf8_bin
    - require:
      - sls: mysql.server
  mysql_user.present:
    - name: {{ dbuser }}
    - host: '{{ dbhost }}'
    - password: {{ dbpass }}
    {%- if dbroot_user and dbroot_pass %}
    - connection_host: {{ dbhost }}
    - connection_user: {{ dbroot_user }}
    - connection_pass: {{ dbroot_pass }}
    {%- endif %}
    - require:
      - mysql_database: bacula_db
  mysql_grants.present:
    - grant: all privileges
    - database: {{ dbname }}.*
    - user: {{ dbuser }}
    - host: '{{ dbhost }}'
    {%- if dbroot_user and dbroot_pass %}
    - connection_host: {{ dbhost }}
    - connection_user: {{ dbroot_user }}
    - connection_pass: {{ dbroot_pass }}
    {%- endif %}
    - require:
      - mysql_database: bacula_db
      - mysql_user: bacula_db
    - require_in:
      - service: install_bacula_director

