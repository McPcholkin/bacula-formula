{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.sd.install

{# ---- STORAGE start ---- #}
{% if map.director.simple %}
  {% set sd_name = map.director.config.director.name %}
{% else %}
  {% set sd_name = map.sd.config.storage.name %}
{% endif %}
{% set sd_port = map.sd.config.storage.port %}
{% set sd_work_dir = map.sd.config.storage.work_dir %}
{% set sd_pid_dir = map.sd.config.storage.pid_dir %}
{% set sd_max_jobs = map.sd.config.storage.max_jobs %}
{% set sd_hb_int = map.sd.config.storage.hb_int %}
{# ---- STORAGE end ---- #}

{# ---- DIR start ---- #}
{% if map.director.simple %}
  {% set sd_dirP_name = map.director.config.director.name %}
  {% set sd_dirR_name = map.director.config.director.name %}
{% else %}
  {% set sd_dirP_name = map.sd.config.director_permitted.name %}
  {% set sd_dirR_name = map.sd.config.director_restricted.name %}
{% endif %}
{% set sd_dirP_password = map.sd.config.director_permitted.password %}
{% set sd_dirR_password = map.sd.config.director_restricted.password %}
{% set sd_dirR_mon = map.sd.config.director_restricted.mon %}
{# ---- DIR end ---- #}

{# ---- MESSAGE start ---- #}
{% set sd_mess_name = map.sd.config.messages.name %}
{% if map.director.simple %}
  {% set sd_mess_director = map.director.config.director.name %}
{% else %}
  {% set sd_mess_director = map.sd.config.messages.director %}
{% endif %}
{# ---- MESSAGE end ---- #} 

bacula_sd_main_config:
  file.managed:
    - name: {{ map.sd.config_path }}
    - source: salt://bacula/files/sd.jinja
    - template: jinja
    - mode: 640
    - makedirs: True
    - user: {{ map.sd.user }}
    - group: {{ map.sd.group }}
    - context:
      {# ----- VAR ----- #}
      config_dir: {{ map.sd.config_dir }}
{# -------------------------------------------------------- #}
      sd_name: {{ sd_name }}
      sd_port: {{ sd_port }}
      sd_work_dir: {{ sd_work_dir }}
      sd_pid_dir: {{ sd_pid_dir }}
      sd_max_jobs: {{ sd_max_jobs }}
      sd_hb_int: '{{ sd_hb_int }}'
{# -------------------------------------------------------- #}
      sd_dirP_name: {{ sd_dirP_name }}
      sd_dirR_name: {{ sd_dirR_name }}
      sd_dirP_password: '{{ sd_dirP_password }}'
      sd_dirR_password: '{{ sd_dirR_password }}'
      sd_dirR_mon: '{{ sd_dirR_mon }}'
{# -------------------------------------------------------- #}      
      sd_mess_name: {{ sd_mess_name }}
      sd_mess_director: {{ sd_mess_director }}
      {# ----- VAR ----- #}
    - require:
      - pkg: install_bacula_sd
    - watch_in:
      - service: install_bacula_sd

dummy_file_to_include_configs_in_sd:
  file.managed:
    - name: {{ map.sd.config_dir }}/dummy.conf
    - contents:
      - '#dummy file'
    - makedirs: True
    - user: {{ map.sd.user }}
    - group: {{ map.sd.group }}
    - require_in:
      - file: bacula_sd_main_config

