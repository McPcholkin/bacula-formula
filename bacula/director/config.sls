{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.director.install

{# ---- DIRECTOR start ---- #}
{% set dir_name = map.director.config.director.name %}
{% set dir_pass = map.director.config.director.password %}
{% set dir_port = map.director.config.director.port %}
{% set dir_query = map.director.config.director.query %}
{% set dir_work_dir = map.director.config.director.work_dir %}
{% set dir_pid_dir = map.director.config.director.pid_dir %}
{% set dir_max_jobs = map.director.config.director.max_jobs %}
{% set dir_messages = map.director.config.director.messages %}
{% set dir_hb_interval = map.director.config.director.hb_interval %}
{# ---- DIRECTOR end ---- #}

{# ---- CATALOG start ---- #}
{% set cat_name = map.director.config.catalog.name %}
{% set cat_db_name = map.director.config.catalog.db_name %}
{% set cat_db_address = map.director.config.catalog.db_address %}
{% set cat_db_user = map.director.config.catalog.db_user %}
{% set cat_db_password = map.director.config.catalog.db_password %}
{# ---- CATALOG end ---- #}

{# ---- RESTORE JOB start ---- #}
{% set restJ_name = map.director.config.restore_job.name %}
{% set restJ_type = map.director.config.restore_job.type %}

{% if map.director.simple %}
  {% set restJ_client = map.director.config.director.name %}
{% else %}
  {% set restJ_client = map.director.config.restore_job.client %}
{% endif %}

{% set restJ_fileset = map.director.config.restore_job.fileset %}
{% set restJ_storage = map.director.config.restore_job.storage %}
{% set restJ_pool = map.director.config.restore_job.pool %}
{% set restJ_messages = map.director.config.restore_job.messages %}
{% set restJ_where = map.director.config.restore_job.where %}
{# ---- RESTORE JOB end ---- #}

{# ---- RESTORE CLIENT start ---- #}
{% if map.director.simple %}
  {% set restC_name = map.director.config.director.name %}
  {% set restC_catalog = map.director.config.catalog.name %}
  {% set restC_address = map.director.fqdn %}
  {% set restC_port = map.fd.config.fd.port %}
  {% set restC_password = map.fd.config.director_permitted.password %}
{% else %}
  {% set restC_name = map.director.config.restore_client.name %}
  {% set restC_catalog = map.director.config.restore_client.catalog %}
  {% set restC_address = map.director.config.restore_client.address %}
  {% set restC_port = map.director.config.restore_client.port %}
  {% set restC_password = map.director.config.restore_client.password %}
{% endif %}

{% set restC_Fret = map.director.config.restore_client.Fret %}
{% set restC_Jret = map.director.config.restore_client.Jret %}
{% set restC_autoprune = map.director.config.restore_client.autoprune %}
{# ---- RESTORE CLIENT end ---- #}

{# ---- RESTORE POOL start ---- #}
{% set restP_name = map.director.config.restore_pool.name %}
{% set restP_type = map.director.config.restore_pool.type %}
{% set restP_rec = map.director.config.restore_pool.rec %}
{% set restP_autoprune = map.director.config.restore_pool.autoprune %}
{% set restP_ret = map.director.config.restore_pool.ret %}
{# ---- RESTORE POOL end ---- #}

{# ---- RESTORE STORAGE start ---- #}
{% set restS_name = map.director.config.restore_storage.name %}

{% if map.director.simple %}
  {% set restS_address = map.director.fqdn %}
  {% set restS_password = map.sd.config.director_permitted.password %}
  {% set restS_port = map.sd.config.storage.port %}
  {% set restS_dev = map.director.config.director.name %}
  {% set restS_type = map.director.config.director.name %}
{% else %}
  {% set restS_address = map.director.config.restore_storage.address %}
  {% set restS_password = map.director.config.restore_storage.password %}
  {% set restS_port = map.director.config.restore_storage.port %}
  {% set restS_dev = map.director.config.restore_storage.dev %}
  {% set restS_type = map.director.config.restore_storage.type %}
{% endif %}
{# ---- RESTORE STORAGE end ---- #}

{# ---- RESTORE FS start ---- #}
{% set restFS_name = map.director.config.restore_fileset.name %}
{# ---- RESTORE FS end ---- #}

{# ---- MONITOR start ---- #}
{% if map.director.simple %}
  {% set mon_name = map.director.config.director.name %}
{% else %}
  {% set mon_name = map.director.config.monitor.name %}
{% endif %}
{% set mon_password = map.director.config.monitor.password %}
{% set mon_acl = map.director.config.monitor.acl %}
{# ---- MONITOR end ---- #}


bacula_director_main_config:
  file.managed:
    - name: {{ map.director.config_path }}
    - source: salt://bacula/files/director.jinja
    - template: jinja
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - context:
      {# ----- VAR ----- #}
      config_dir: {{ map.director.config_dir }}
{# -------------------------------------------------------- #}
      dir_name: {{ dir_name }}
      dir_pass: '{{ dir_pass }}'
      dir_port: {{ dir_port }}
      dir_query: '{{ dir_query }}'
      dir_work_dir: '{{ dir_work_dir }}'
      dir_pid_dir: '{{ dir_pid_dir }}'
      dir_max_jobs: {{ dir_max_jobs }}
      dir_messages: {{ dir_messages }}
      dir_hb_interval: '{{ dir_hb_interval }}'
{# -------------------------------------------------------- #}
      cat_name: {{ cat_name }}
      cat_db_name: '{{ cat_db_name }}'
      cat_db_address: '{{ cat_db_address }}'
      cat_db_user: {{ cat_db_user }}
      cat_db_password: '{{ cat_db_password }}'    # used in mysql
{# -------------------------------------------------------- #}
      restJ_name: '{{ restJ_name }}'
      restJ_type: {{ restJ_type }}
      restJ_client: {{ restJ_client }}
      restJ_fileset: '{{ restJ_fileset }}'
      restJ_storage: '{{ restJ_storage }}'
      restJ_pool: {{ restJ_pool }}
      restJ_messages: {{ restJ_messages }}
      restJ_where: '{{ restJ_where }}'
{# -------------------------------------------------------- #}
      restC_name: {{ restC_name }}
      restC_address: {{ restC_address }}
      restC_port: {{ restC_port }}
      restC_catalog: {{ restC_catalog }}
      restC_password: '{{ restC_password }}'
      restC_Fret: '{{ restC_Fret }}'
      restC_Jret: '{{ restC_Jret }}'
      restC_autoprune: {{ restC_autoprune }}
{# -------------------------------------------------------- #}
      restP_name: {{ restP_name }}
      restP_type: {{ restP_type }}
      restP_rec: '{{ restP_rec }}'
      restP_autoprune: '{{ restP_autoprune }}'
      restP_ret: '{{ restP_ret }}'
{# -------------------------------------------------------- #}
      restS_name: {{ restS_name }}
      restS_address: {{ restS_address }}
      restS_port: {{ restS_port }}
      restS_password: '{{ restS_password }}'
      restS_dev: {{ restS_dev }}
      restS_type: {{ restS_type }}
{# -------------------------------------------------------- #}
      restFS_name: {{ restFS_name }}
{# -------------------------------------------------------- #}
      mon_name: {{ mon_name }}
      mon_password: {{ mon_password }}
      mon_acl: {{ mon_acl }}
      {# ----- VAR ----- #}
    - require:
      - pkg: install_bacula_director
    - watch_in:
      - service: install_bacula_director

dummy_file_to_include_configs_to_director_config:
  file.managed:
    - name: {{ map.director.config_dir }}/dummy.conf
    - contents:
      - '#dummy file'
    - makedirs: True
    - require_in:
      - file: bacula_director_main_config

create_restore_dir_on_{{ dir_name }}:
  file.directory:
    - name: {{ restJ_where }}
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - makedirs: True
