{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.sd.install

bacula_sd_main_config:
  file.managed:
    - name: {{ map.sd.config_path }}
    - source: salt://bacula/files/sd.jinja
    - template: jinja
    - mode: 640
    - makedirs: True
    - context:
      config: {{ map.sd.config }}
      config_dir: {{ map.sd.config_dir }}
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
    - require_in:
      - file: bacula_sd_main_config

