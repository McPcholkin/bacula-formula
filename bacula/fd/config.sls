{%- from "bacula/map.jinja" import map with context -%}

include:
  - bacula.fd.install

fd_config:
  file.managed:
    - name: {{ map.fd.config_path }}
    - source: salt://bacula/files/fd.jinja
    - template: jinja
    - mode: 640
    - makedirs: True
    - context:
      config: {{ map.fd.config }}
    - require:
      - pkg: install_bacula_fd
    - watch_in:
      - service: install_bacula_fd
