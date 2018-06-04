{%- from "bacula/map.jinja" import map with context -%}

install_bacula_fd:
  pkg.installed:
    - name: {{ map.fd.pkg }}
  service.running:
    - name: {{ map.fd.service }}
    - enable: True
    - require: 
      - pkg: install_bacula_fd
