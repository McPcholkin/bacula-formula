{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.director.install

bacula_director_main_config:
  file.managed:
    - name: {{ map.director.config_path }}
    - source: salt://bacula/files/director.jinja
    - template: jinja
    - context:
      config: {{ map.director.config }}
      config_dir: {{ map.director.config_dir }}
    - require:
      - pkg: install_bacula_director
    - watch_in:
      - service: install_bacula_director

dummy_file_to_include_configs_director:
  file.managed:
    - name: {{ map.director.config_dir }}/dummy.conf
    - contents:
      - '#dummy file'
    - makedirs: True
    - require_in:
      - file: bacula_director_main_config
