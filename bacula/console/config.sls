{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.console.install

bconsole_config:
  file.managed:
    - name: {{ map.console.config_path }}
    - source: salt://bacula/files/bconsole.jinja
    - template: jinja
    - mode: 640
    - makedirs: True
    - context:
      config: {{ map.console.config }}
    - require:
      - pkg: install_bacula_console
