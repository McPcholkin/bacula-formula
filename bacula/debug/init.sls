
debug_bacula_map:
  file.managed:
    - name: /srv/bacula_map_debug.txt
    - source: salt://bacula/debug/map_debug.jinja
    - template: jinja
