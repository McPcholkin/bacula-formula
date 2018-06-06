{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.sd.install

{% for client in map.clients %}

{% set dev_name = salt['pillar.get']('bacula:clients:'~client~':sd:name', 'FileStorage-'~client) %}
{% set dev_arch = salt['pillar.get']('bacula:clients:'~client~':sd:dev_arch', map.sd.storage~'/'~client) %}
{% set dev_type = salt['pillar.get']('bacula:clients:'~client~':sd:dev_type', map.sd.clients_defaults.dev_type) %}
{% set med_type = salt['pillar.get']('bacula:clients:'~client~':sd:med_type', 'File-'~client) %}
{% set med_rem  = salt['pillar.get']('bacula:clients:'~client~':sd:med_rem', map.sd.clients_defaults.med_rem) %} 
{% set ran_acc  = salt['pillar.get']('bacula:clients:'~client~':sd:ran_acc', map.sd.clients_defaults.ran_acc) %}
{% set med_labl = salt['pillar.get']('bacula:clients:'~client~':sd:med_labl', map.sd.clients_defaults.med_labl) %}
{% set auto_mnt = salt['pillar.get']('bacula:clients:'~client~':sd:auto_mnt', map.sd.clients_defaults.auto_mnt) %}
{% set alw_open = salt['pillar.get']('bacula:clients:'~client~':sd:alw_open', map.sd.clients_defaults.alw_open) %}
{% set max_buff = salt['pillar.get']('bacula:clients:'~client~':sd:max_buff', map.sd.clients_defaults.max_buff) %}

bacula_sd_config_for_{{ client }}:
  file.managed:
    - name: {{ map.sd.config_dir }}/{{ client }}.conf
    - source: salt://bacula/files/client.sd.jinja
    - template: jinja
    - makedirs: True
    - context:
      {# ---- VAR ----- #}
      client: {{ client }}
      dev_name: {{ dev_name }}
      dev_arch: {{ dev_arch }}
      dev_type: {{ dev_type }}
      med_type: {{ med_type }}
      med_rem: '{{ med_rem }}'
      ran_acc: '{{ ran_acc }}'
      med_labl: '{{ med_labl }}'
      auto_mnt: '{{ auto_mnt }}'
      alw_open: '{{ alw_open }}'
      max_buff: {{ max_buff }}
      {# ----- VAR ----- #}
    - require:
      - pkg: install_bacula_sd
    - watch_in:
      - service: install_bacula_sd

create_directory_for_store_{{ client }}_backups:
  file.directory:
    - name: {{ dev_arch }}
    - user: {{ map.sd.user }}
    - group: {{ map.sd.group }}
    - makedirs: True
    

{% endfor %}
