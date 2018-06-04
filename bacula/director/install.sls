{%- from "bacula/map.jinja" import map with context -%}

install_bacula_director:
  pkg.installed:
    - pkgs: {{ map.director.pkgs }}
  service.running:
    - name: {{ map.director.service }}
    - enable: True
    - require:
      - pkg: install_bacula_director

