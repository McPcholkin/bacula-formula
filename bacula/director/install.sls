{%- from "bacula/map.jinja" import map with context -%}

install_bacula_director:
  pkg.installed:
    - pkgs: {{ map.director.pkgs }}
  service.running:
    - name: {{ map.director.service }}
    - enable: True
    - require:
      - pkg: install_bacula_director

create_catalog_backup_script:
  file.managed:
    - name: {{ map.director.scripts }}/make_catalog_backup.sh
    - mode: 700
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - makedirs: true
    - source: salt://bacula/files/scripts/make_catalog_backup.sh

create_clean_catalog_backup_script:
  file.managed:
    - name: {{ map.director.scripts }}/delete_catalog_backup.sh
    - mode: 700
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - makedirs: true
    - source: salt://bacula/files/scripts/delete_catalog_backup.sh

create_easy_backup_catalog_script:
  file.managed:
    - name: {{ map.director.scripts }}/easy_catalog_backup.sh
    - mode: 700
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - makedirs: true
    - contents:
      - '#!/bin/bash'
      - '# easy backup catalog DB'
      - '#'
      - {{ map.director.scripts }}/make_catalog_backup.sh {{ map.director.config.catalog.db_name }} {{ map.director.config.catalog.db_user }} {{ "'" }}{{ map.director.config.catalog.db_password }}{{ "'" }} {{ map.director.config.catalog.db_address }} {{ map.director.dbtype }}

create_easy_backup_catalog_remove_script:
  file.managed:
    - name: {{ map.director.scripts }}/easy_catalog_backup_remove.sh
    - mode: 700
    - user: {{ map.director.user }}
    - group: {{ map.director.group }}
    - makedirs: true
    - contents:
      - '#!/bin/bash'
      - '# easy remove backup catalog DB'
      - '#'
      - '{{ map.director.scripts }}/delete_catalog_backup.sh {{ map.director.config.catalog.db_name }}'
