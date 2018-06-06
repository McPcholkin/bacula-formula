{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.director.install

create_bootstrap_dir:
  file.directory:
    - name: {{ map.director.bootstrap_dir }}
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - makedirs: True 


{% for client in map.clients %}

{# ---- JOB start ---- #}
{% set job_type = salt['pillar.get']('bacula:clients:'~client~':dir:job:type', map.director.clients_defaults.job.type) %}
{% set job_name = salt['pillar.get']('bacula:clients:'~client~':dir:job:name', client~'_Backup') %}
{% set job_level = salt['pillar.get']('bacula:clients:'~client~':dir:job:level', map.director.clients_defaults.job.level) %}
{% set job_base = salt['pillar.get']('bacula:clients:'~client~':dir:job:base', False) %}
{% set job_accurate = salt['pillar.get']('bacula:clients:'~client~':dir:job:accurate', map.director.clients_defaults.job.accurate) %}
{% set job_spool = salt['pillar.get']('bacula:clients:'~client~':dir:job:spool', map.director.clients_defaults.job.spool) %}
{% set job_bootstrap = salt['pillar.get']('bacula:clients:'~client~':dir:job:bootstrap', map.director.bootstrap_dir~'/'~client~'-JobID-%i.bsr') %}
{% set job_client_before = salt['pillar.get']('bacula:clients:'~client~':dir:job:client_before', False) %}
{% set job_client_after = salt['pillar.get']('bacula:clients:'~client~':dir:job:client_after', False) %}
{% set job_before = salt['pillar.get']('bacula:clients:'~client~':dir:job:before', False) %}
{% set job_after = salt['pillar.get']('bacula:clients:'~client~':dir:job:after', False) %}
{% set job_client = salt['pillar.get']('bacula:clients:'~client~':dir:job:client', client~'-fd') %}
{% set job_fileset = salt['pillar.get']('bacula:clients:'~client~':dir:job:fileset', client) %}
{% set job_messages = salt['pillar.get']('bacula:clients:'~client~':dir:job:messages', map.director.clients_defaults.job.messages) %}
{% set job_pool = salt['pillar.get']('bacula:clients:'~client~':dir:job:pool', client~'-monthly') %}
{% set job_schedule = salt['pillar.get']('bacula:clients:'~client~':dir:job:schedule', client~'-year') %}
{% set job_storage = salt['pillar.get']('bacula:clients:'~client~':dir:job:storage', 'FileStorage-'~client) %}
{% set job_prior = salt['pillar.get']('bacula:clients:'~client~':dir:job:prior', False) %}
{# ---- JOB end ---- #}

{# ---- FILESET start ---- #}
{% set fileset = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:name', client) %}
{% set fs_comp = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:comp', map.director.clients_defaults.fileset.comp) %}
{% set fs_sig = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:sig', map.director.clients_defaults.fileset.sig) %}
{% set fs_onefs = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:onefs', map.director.clients_defaults.fileset.onefs) %}
{% set fs_noat = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:noat', map.director.clients_defaults.fileset.noat) %}
{% set fs_check = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:check', map.director.clients_defaults.fileset.check) %}
{% set fs_ign_case = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:ign_case', False) %}
{% set fs_vss = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:vss', False) %}
{% set fs_portable = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:portable', False) %}
{% set fs_acl = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:acl', map.director.clients_defaults.fileset.acl) %}

{# --- use default include / exclude templates in simple mode --- #}
{% if map.director.simple and salt['pillar.get']('bacula:clients:'~client~':os', False) == 'linux' %}
  {% set fs_default_linux = map.director.clients_defaults.fileset.fs_defaults.linux %}
  {% set fs_client = salt['pillar.get']('bacula:clients:'~client~':dir:fileset', {}) %}
  {% set fs_merged = salt['slsutil.merge'](fs_default_linux, fs_client, merge_lists=True) %}

  {% set fs_include = fs_merged.include %}
  {% set fs_exclude = fs_merged.exclude %}

  {% set fs_exclude_win = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:exclude_win', False) %}
  {% set fs_wildfile = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:wildfile', map.director.clients_defaults.fileset.wildfile) %}
  {% set fs_wilddir = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:wilddir', map.director.clients_defaults.fileset.wilddir) %}

{% elif map.director.simple and salt['pillar.get']('bacula:clients:'~client~':os', False) == 'windows' %}
{# --- win client --- #}
  {% set fs_exclude_win = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:exclude_win', 'yes') %}
  {% set fs_default_windows = map.director.clients_defaults.fileset.fs_defaults.windows %}
  {% set fs_client = salt['pillar.get']('bacula:clients:'~client~':dir:fileset', {}) %}
  {% set fs_merged = salt['slsutil.merge'](fs_default_windows, fs_client, merge_lists=True) %}
  
  {% set fs_wildfile = fs_merged.wildfile %}
  {% set fs_wilddir = fs_merged.wilddir %}

  {% set fs_include = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:include', False) %}
  {% set fs_exclude = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:exclude', False) %}
  
{% else %}
  {% set fs_include = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:include', False) %}
  {% set fs_exclude = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:exclude', False) %} 
  {% set fs_exclude_win = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:exclude_win', False) %}
  {% set fs_wildfile = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:wildfile', map.director.clients_defaults.fileset.wildfile) %}
  {% set fs_wilddir = salt['pillar.get']('bacula:clients:'~client~':dir:fileset:wilddir', map.director.clients_defaults.fileset.wilddir) %}
{% endif %}
{# --- end default include --- #}
{# ---- FILESET end ---- #}

{# ---- SCHEDULE start ---- #}
{% set schedule_name = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:name', client~'-year') %}

{# ---- SCHEDULE MON start ---- #}
{% set schedule_mon_enabled = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:mon:enabled', False) %}
{% set schedule_mon_level = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:mon:level', map.director.clients_defaults.schedule.mon.level) %}
{% set schedule_mon_pool = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:mon:pool', client~'-monthly') %}
{% set schedule_mon_day = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:mon:day', map.director.clients_defaults.schedule.mon.day) %}
{% set schedule_mon_time = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:mon:time', map.director.clients_defaults.schedule.mon.time) %}
{# ---- SCHEDULE MON end ---- #}

{# ---- SCHEDULE WEEK start ---- #}
{% set schedule_week_enabled = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:week:enabled', False) %}
{% set schedule_week_level = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:week:level', map.director.clients_defaults.schedule.week.level) %}
{% set schedule_week_pool = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:week:pool', client~'-weekly') %}
{% set schedule_week_day = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:week:day', map.director.clients_defaults.schedule.week.day) %}
{% set schedule_week_time = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:week:time', map.director.clients_defaults.schedule.week.time) %}
{# ---- SCHEDULE WEEK end ---- #}

{# ---- SCHEDULE DAY start ---- #}
{% set schedule_day_enabled = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:day:enabled', False) %}
{% set schedule_day_level = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:day:level', map.director.clients_defaults.schedule.day.level) %}
{% set schedule_day_pool = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:day:pool', client~'-daily') %}
{% set schedule_day_day = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:day:day', map.director.clients_defaults.schedule.day.day) %}
{% set schedule_day_time = salt['pillar.get']('bacula:clients:'~client~':dir:schedule:day:time', map.director.clients_defaults.schedule.day.time) %}
{# ---- SCHEDULE DAY end ---- #}

{# ---- SCHEDULE end ---- #}

{# ---- CLIENT start ---- #}
{% set client_fqdn = salt['pillar.get']('bacula:clients:'~client~':dir:client:fqdn', False) %}
{% set client_name = salt['pillar.get']('bacula:clients:'~client~':dir:client:name', client~'-fd') %}
{% set client_port = salt['pillar.get']('bacula:clients:'~client~':dir:client:port', map.director.clients_defaults.client.port) %}
{% set client_catalog = salt['pillar.get']('bacula:clients:'~client~':dir:client:catalog', map.director.config.catalog.name) %}
{% set client_password = salt['pillar.get']('bacula:clients:'~client~':dir:client:password', map.director.clients_defaults.client.password) %}
{% set client_file_ret = salt['pillar.get']('bacula:clients:'~client~':dir:client:file_ret', map.director.clients_defaults.client.file_ret) %}
{% set client_job_ret = salt['pillar.get']('bacula:clients:'~client~':dir:client:job_ret', map.director.clients_defaults.client.job_ret) %}
{% set client_autoprune = salt['pillar.get']('bacula:clients:'~client~':dir:client:autoprune', map.director.clients_defaults.client.autoprune) %}
{# ----  CLIENT end ---- #}

{# ---- STORAGE start ---- #}
{% if map.director.simple %}
  {% set sorage_fqdn = salt['pillar.get']('bacula:clients:'~client~':dir:storage:fqdn', map.director.fqdn) %}
  {% set storage_password = salt['pillar.get']('bacula:clients:'~client~':dir:storage:password', map.sd.config.director_permitted.password) %}
{% else %}
  {% set storage_fqdn = salt['pillar.get']('bacula:clients:'~client~':dir:storage:fqdn', False) %}
  {% set storage_password = salt['pillar.get']('bacula:clients:'~client~':dir:storage:password', map.director.clients_defaults.storage.password) %}
{% endif %}

{% set storage_name = salt['pillar.get']('bacula:clients:'~client~':dir:storage:name', 'FileStorage-'~client) %}
{% set storage_port = salt['pillar.get']('bacula:clients:'~client~':dir:storage:port', map.director.clients_defaults.storage.port) %}
{% set storage_dev = salt['pillar.get']('bacula:clients:'~client~':dir:storage:dev', 'FileStorage-'~client) %}
{% set storage_med = salt['pillar.get']('bacula:clients:'~client~':dir:storage:med', 'File-'~client) %}
{# ---- STORAGE end ---- #}

{# ---- POOL start ---- #}

{# ---- POOL MON start ---- #}
{% set pool_mon_name = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:name', client~'-monthly') %}
{% set pool_mon_type = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:type', map.director.clients_defaults.pool.mon.type) %}
{% set pool_mon_maxj = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:maxj', map.director.clients_defaults.pool.mon.maxj) %}
{% set pool_mon_maxb = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:maxb', map.director.clients_defaults.pool.mon.maxb) %}
{% set pool_mon_ret = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:ret', map.director.clients_defaults.pool.mon.ret) %}
{% set pool_mon_autoprune = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:autoprune', map.director.clients_defaults.pool.mon.autoprune) %}
{% set pool_mon_rec_pool = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:rec_pool', client~'-monthly') %}
{% set pool_mon_rec = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:rec', map.director.clients_defaults.pool.mon.rec) %}
{% set pool_mon_rec_old = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:rec_old', map.director.clients_defaults.pool.mon.rec_old) %}
{% set pool_mon_labl_form = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:labl_form', client~'-monthly-') %}
{% set pool_mon_stor = salt['pillar.get']('bacula:clients:'~client~':dir:pool:mon:stor', 'FileStorage-'~client) %}
{# ---- POOL MON end ---- #}

{# ---- POOL WEEK start ---- #}
{% set pool_week_name = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:name', client~'-weekly') %}
{% set pool_week_type = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:type', map.director.clients_defaults.pool.week.type) %}
{% set pool_week_maxj = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:maxj', map.director.clients_defaults.pool.week.maxj) %}
{% set pool_week_maxb = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:maxb', map.director.clients_defaults.pool.week.maxb) %}
{% set pool_week_ret = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:ret', map.director.clients_defaults.pool.week.ret) %}
{% set pool_week_autoprune = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:autoprune', map.director.clients_defaults.pool.week.autoprune) %}
{% set pool_week_rec_pool = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:rec_pool', client~'-weekly') %}
{% set pool_week_rec = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:rec', map.director.clients_defaults.pool.week.rec) %}
{% set pool_week_rec_old = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:rec_old', map.director.clients_defaults.pool.week.rec_old) %}
{% set pool_week_labl_form = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:labl_form', client~'-weekly-') %}
{% set pool_week_stor = salt['pillar.get']('bacula:clients:'~client~':dir:pool:week:stor', 'FileStorage-'~client) %}
{# ---- POOL WEEK end ---- #}

{# ---- POOL DAY start ---- #}
{% set pool_day_name = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:name', client~'-daily') %}
{% set pool_day_type = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:type', map.director.clients_defaults.pool.day.type) %}
{% set pool_day_vol_use = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:vol_use', map.director.clients_defaults.pool.day.vol_use) %}
{% set pool_day_maxb = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:maxb', map.director.clients_defaults.pool.day.maxb) %}
{% set pool_day_ret = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:ret', map.director.clients_defaults.pool.day.ret) %}
{% set pool_day_autoprune = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:autoprune', map.director.clients_defaults.pool.day.autoprune) %}
{% set pool_day_rec_pool = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:rec_pool', client~'-daily') %}
{% set pool_day_rec = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:rec', map.director.clients_defaults.pool.day.rec) %}
{% set pool_day_rec_old = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:rec_old', map.director.clients_defaults.pool.day.rec_old) %}
{% set pool_day_labl_form = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:labl_form', client~'-daily-') %}
{% set pool_day_stor = salt['pillar.get']('bacula:clients:'~client~':dir:pool:day:stor', 'FileStorage-'~client) %}
{# ---- POOL DAY end ---- #}

{# ---- POOL BASE start ---- #}
{% set pool_base_name = salt['pillar.get']('bacula:clients:'~client~':dir:pool:base:name', client) %}
{% set pool_base_type = salt['pillar.get']('bacula:clients:'~client~':dir:pool:base:type', map.director.clients_defaults.pool.base.type) %}
{% set pool_base_maxb = salt['pillar.get']('bacula:clients:'~client~':dir:pool:base:maxb', map.director.clients_defaults.pool.base.maxb) %}
{% set pool_base_labl_form = salt['pillar.get']('bacula:clients:'~client~':dir:pool:base:labl_form', client) %}
{% set pool_base_stor = salt['pillar.get']('bacula:clients:'~client~':dir:pool:base:stor', 'FileStorage-'~client) %}
{# ---- POOL BASE end ---- #}

{# ---- POOL end ---- #}

create_bacula_director_config_for_{{ client }}:
  file.managed:
    - name: {{ map.director.config_dir }}/{{ client }}.conf
    - source: salt://bacula/files/client.dir.jinja
    - template: jinja
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - makedirs: True
    - context:
      {# ---- VAR ----- #}
      client: {{ client }}
      job_name: {{ job_name }}            # Client Name (Uniq)
      job_type: {{ job_type }}            # type of job
      job_level: {{ job_level }}          # default backup level (real in Shedule section)
      job_base: {{ job_base }}            # Job name required for dedupe using base jobs
      job_accurate: '{{ job_accurate }}'  # Required to avoid putting jobs in DB before completion (avoids cancelled jobs in the DB)
      job_spool: '{{ job_spool }}'  
      job_bootstrap: '{{ job_bootstrap }}'          # bootstrap file
      job_client_before: {{ job_client_before }}    # run on client before backup
      job_client_after: {{ job_client_after }}      # job run on client after backup
      job_before: {{ job_before }}                  # job run on director before backu
      job_after: {{ job_after }}                    # job run on director after backup
      job_client: {{ job_client }}                  # name of client file demon
      job_fileset: {{ job_fileset }}                # File Set (uniq for platform) 
      job_prior: {{ job_prior }}                    # run after main backup
      job_messages: {{ job_messages }}       
      job_pool: {{ job_pool }}                # Default Pool (real in Shedule section)
      job_schedule: {{ job_schedule }}        # Used Shedule scheme
      job_storage: {{ job_storage }}          # Default Storage (real in Shedule section)
{# -------------------------------------------------------------------------------------- #}
      fileset: {{ fileset }}                  # uniq client
      fs_vss: '{{ fs_vss }}'                  # for TC compatibility
      fs_comp: {{ fs_comp }}                  # Compress ratio
      fs_sig: {{ fs_sig }}                    # hash summ alg.
      fs_onefs: '{{ fs_onefs }}'            
      fs_portable: '{{ fs_portable }}'        # removable device
      fs_acl: '{{ fs_acl }}'                  # support ext FS
      fs_noat: '{{ fs_noat }}'                # not update read time at backup file
      fs_check: '{{ fs_check }}'              
      fs_ign_case: '{{ fs_ign_case }}'        # for windows clients
      fs_exclude_win: '{{ fs_exclude_win }}'
      fs_wildfile: {{ fs_wildfile }}          # Exclude media and temp files
      fs_wilddir: {{ fs_wilddir }}
      fs_include: {{ fs_include }}
      fs_exclude: {{ fs_exclude }}
{# -------------------------------------------------------------------------------------- #}
      schedule_name: {{ schedule_name }}      # 
      schedule_mon_enabled: {{ schedule_mon_enabled }}
      schedule_mon_level: '{{ schedule_mon_level }}'
      schedule_mon_pool: {{ schedule_mon_pool }}
      schedule_mon_day: '{{ schedule_mon_day }}'
      schedule_mon_time: '{{ schedule_mon_time }}'
      schedule_week_enabled: {{ schedule_week_enabled }}
      schedule_week_level: '{{ schedule_week_level }}'
      schedule_week_pool: {{ schedule_week_pool }}
      schedule_week_day: '{{ schedule_week_day }}'
      schedule_week_time: '{{ schedule_week_time }}'
      schedule_day_enabled: {{ schedule_day_enabled }}
      schedule_day_level: '{{ schedule_day_level }}'
      schedule_day_pool: {{ schedule_day_pool }}
      schedule_day_day: '{{ schedule_day_day }}'
      schedule_day_time: '{{ schedule_day_time }}'
{# -------------------------------------------------------------------------------------- #}
      client_fqdn: {{ client_fqdn }}  
      client_name: {{ client_name }}
      client_port: {{ client_port }}
      client_catalog: {{ client_catalog }}  
      client_password: '{{ client_password }}'
      client_file_ret: {{ client_file_ret }}    # Real retention period in Pool section
      client_job_ret: {{ client_job_ret }}
      client_autoprune: '{{ client_autoprune }}'  # Prune expired Jobs/Files
{# -------------------------------------------------------------------------------------- #}
      storage_fqdn: {{ sorage_fqdn }}
      storage_name: {{ storage_name }}
      storage_port: {{ storage_port }}
      storage_password: '{{ storage_password }}'
      storage_dev: {{ storage_dev }}
      storage_med: {{ storage_med }}
{# -------------------------------------------------------------------------------------- #}
      pool_mon_name: {{ pool_mon_name }}
      pool_mon_type: {{ pool_mon_type }}
      pool_mon_maxj: {{ pool_mon_maxj }}
      pool_mon_maxb: {{ pool_mon_maxb }}      #  DVD-R size
      pool_mon_ret: {{ pool_mon_ret }}
      pool_mon_autoprune: {{ pool_mon_autoprune }}
      pool_mon_rec_pool: {{ pool_mon_rec_pool }}
      pool_mon_rec: {{ pool_mon_rec }}
      pool_mon_rec_old: {{ pool_mon_rec_old }}
      pool_mon_labl_form: {{ pool_mon_labl_form }}
      pool_mon_stor: {{ pool_mon_stor }}
      pool_week_name: {{ pool_week_name }}
      pool_week_type: {{ pool_week_type }}
      pool_week_maxj: {{ pool_week_maxj }}
      pool_week_maxb: {{ pool_week_maxb }}    #  DVD-R size
      pool_week_ret: {{ pool_week_ret }}
      pool_week_autoprune: {{ pool_week_autoprune }}
      pool_week_rec_pool: {{ pool_week_rec_pool }}
      pool_week_rec: {{ pool_week_rec }}
      pool_week_rec_old: {{ pool_week_rec_old }}
      pool_week_labl_form: {{ pool_week_labl_form }}
      pool_week_stor: {{ pool_week_stor }}
      pool_day_name: {{ pool_day_name }}
      pool_day_type: {{ pool_day_type }}
      pool_day_vol_use: '{{ pool_day_vol_use }}'
      pool_day_maxb: {{ pool_day_maxb }}      #  DVD-R size
      pool_day_ret: {{ pool_day_ret }}
      pool_day_autoprune: {{ pool_day_autoprune }}
      pool_day_rec_pool: {{ pool_day_rec_pool }}
      pool_day_rec: {{ pool_day_rec }} 
      pool_day_rec_old: {{ pool_day_rec_old }}
      pool_day_labl_form: {{ pool_day_labl_form }}
      pool_day_stor: {{ pool_day_stor }}
      pool_base_name: {{ pool_base_name }}
      pool_base_type: {{ pool_base_type }}
      pool_base_maxb: {{ pool_base_maxb }}
      pool_base_labl_form: {{ pool_base_labl_form }}
      pool_base_stor: {{ pool_base_stor }}
      {# ---- VAR ----- #}
    - require:
      - pkg: install_bacula_director
    - watch_in:
      - service: install_bacula_director

{# ---- add user scripts if exist ---- #}
{% set scripts = salt['pillar.get']('bacula:clients:'~client~':scripts:dir', False) %}
{% if scripts %}

{% for script in scripts %}

create_{{ script }}:
  file.managed:
    - name: {{ map.director.scripts }}/{{ script }}
  {% if '.sh' in script %}
    - mode: 740
  {% elif '.key' in script %}
    - mode: 600
  {% else %}
    - mode: 640
  {% endif %}
    - makedirs: True
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}   
    - contents_pillar: bacula:clients:{{ client }}:scripts:dir:{{ script }}
    - require:
      - pkg: install_bacula_director
    - watch_in:
      - service: install_bacula_director

{% endfor %}
{% endif %}

{% endfor %}

