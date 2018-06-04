{%- from "bacula/map.jinja" import map with context -%}

install_bacula_console:
  pkg.installed:
    - name: {{ map.console.pkg }}
