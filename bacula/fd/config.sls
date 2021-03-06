{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.fd.install

{# ---- DIR start ---- #}
{% if map.director.simple %}
  {% set dirP_name = map.director.config.director.name %}
  {% set dirR_name = map.director.config.director.name %}
{% else %}
  {% set dirP_name = map.fd.config.director_permitted.name %}
  {% set dirR_name = map.fd.config.director_restricted.name %}
{% endif %}
{% set dirP_password = map.fd.config.director_permitted.password %}
{% set dirR_password = map.fd.config.director_restricted.password %}
{% set dirR_mon = map.fd.config.director_restricted.mon %}
{# ---- DIR end ---- #}

{# ---- FD start ---- #}
{% if map.director.simple %}
  {% set fd_name = map.director.config.director.name %}
{% else %}
  {% set fd_name = map.fd.config.fd.name %}
{% endif %}
{% set fd_port = map.fd.config.fd.port %}
{% set fd_work_dir = map.fd.config.fd.work_dir %}
{% set fd_pid_dir = map.fd.config.fd.pid_dir %}
{% set fd_max_jobs = map.fd.config.fd.max_jobs %}
{% set fd_hb_int = map.fd.config.fd.hb_int %}
{# ---- FD end ---- #}

{# ---- MESSAGES start ---- #}
{% if map.director.simple %}
  {% set mess_dir = map.director.config.director.name %}
{% else %}
  {% set mess_dir = map.fd.config.messages.director %}
{% endif %}
{% set mess_name = map.fd.config.messages.name %}
{# ---- MESSAGES end ---- #}

fd_config:
  file.managed:
    - name: {{ map.fd.config_path }}
    - source: salt://bacula/files/fd.jinja
    - template: jinja
    - mode: 640
    - makedirs: True
    - context:
      {# ----- VAR ----- #}
      dirP_name: {{ dirP_name }}
      dirP_password: '{{ dirP_password }}'
      dirR_name: {{ dirR_name }}
      dirR_password: '{{ dirR_password }}'
      dirR_mon: '{{ dirR_mon }}'
      fd_name: {{ fd_name }}
      fd_port: {{ fd_port }}
      fd_work_dir: {{ fd_work_dir }}
      fd_pid_dir: {{ fd_pid_dir }}
      fd_max_jobs: {{ fd_max_jobs }}
      fd_hb_int: {{ fd_hb_int }}
      mess_name: {{ mess_name }}
      mess_dir: {{ mess_dir }}
      {# ----- VAR ----- #}
    - require:
      - pkg: install_bacula_fd
    - watch_in:
      - service: install_bacula_fd
