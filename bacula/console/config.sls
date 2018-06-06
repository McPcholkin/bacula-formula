{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.console.install

{% if map.director.simple %}
  {% set con_name = salt['pillar.get']('bacula:console:config:name', map.director.config.director.name) %}
  {% set con_address = salt['pillar.get']('bacula:console:config:address', map.director.fqdn) %}
  {% set con_password = salt['pillar.get']('bacula:console:config:password', map.director.config.director.password) %}
{% else %}
  {% set con_name = map.console.config.name %}
  {% set con_address = map.console.config.address %}
  {% set con_password = map.console.config.password %}
{% endif %}

{% set con_port = map.console.config.port %}

bconsole_config:
  file.managed:
    - name: {{ map.console.config_path }}
    - source: salt://bacula/files/bconsole.jinja
    - template: jinja
    - mode: 640
    - makedirs: True
    - user: {{ map.console.user }}
    - group: {{ map.console.group }}
    - context:
      {# ---- VAR ----- #}
      con_name: {{ con_name }}
      con_port: {{ con_port }}
      con_address: {{ con_address }}
      con_password: '{{ con_password }}'
      {# ---- VAR ----- #}
    - require:
      - pkg: install_bacula_console
