{%- from "bacula/map.jinja" import map with context -%}

install_bacula_sd:
  pkg.installed:
    - name: {{ map.sd.pkg }}
  service.running:
    - name: {{ map.sd.service }}
    - enable: True
    - require: 
      - pkg: install_bacula_sd

