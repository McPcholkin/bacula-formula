{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.fd.install

{% set client_id = salt['grains.get']('id').split('.') | first %}

{# ---- DIR start ---- #}
{% set dirP_name = map.director.config.director.name %}
{% set dirP_password = salt['pillar.get']('bacula:clients:'~client_id~':dir:client:password') %}
{% set dirR_name = client_id %}
{% set dirR_password = map.fd.config.director_restricted.password %}
{% set dirR_mon = map.fd.config.director_restricted.mon %}
{# ---- DIR end ---- #}
{# ---- FD start ---- #}
{% set fd_name = client_id %}
{% set fd_port = map.fd.config.fd.port %}
{% set fd_work_dir = map.fd.config.fd.work_dir %}
{% set fd_pid_dir = map.fd.config.fd.pid_dir %}
{% set fd_max_jobs = map.fd.config.fd.max_jobs %}
{% set fd_hb_int = map.fd.config.fd.hb_int %}
{# ---- FD end ---- #}
{# ---- MESSAGES start ---- #}
{% set mess_dir = client_id %}
{% set mess_name = map.fd.config.messages.name %}
{# ---- MESSAGES end ---- #}

fd_config_{{ client_id }}:
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


{# ---- add user scripts if exist ---- #}
{% set scripts = salt['pillar.get']('bacula:clients:'~client_id~':scripts:client', False) %}
{% if scripts %}
{% set custom_script_user = salt['pillar.get']('bacula:clients:'~client_id~':scripts:client_user', False) %}
{% set custom_script_group = salt['pillar.get']('bacula:clients:'~client_id~':scripts:client_group', False) %}

{% for script in scripts %}

create_{{ script }}:
  file.managed:
    - name: {{ script }}
  {% if '.sh' in script %}
    - mode: 740
  {% elif '.key' in script %}
    - mode: 600
  {% else %}
    - mode: 640
  {% endif %}
    - makedirs: True
  {% if custom_script_user %}
    - user: {{ custom_script_user }}
  {% else %}
    - user: {{ map.fd.user }}
  {% endif %}

  {% if custom_script_group %}
    - group: {{ custom_script_group }}
  {% else %}
    - group: {{ map.fd.group }}
  {% endif %}
    - contents_pillar: bacula:clients:{{ client_id }}:scripts:client:{{ script }}

{% endfor %}
{% endif %}
