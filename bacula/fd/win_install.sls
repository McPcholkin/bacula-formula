{%- from "bacula/map.jinja" import map with context -%}

install_bacula_fd_win:
  file.managed:
    - name: {{ map.fd.win_scripts }}/bacula_win.exe
    - source: {{ map.fd.win_pkg_url }}
    - source_hash: {{ map.fd.win_pkg_md5 }}
    - makedirs: True
  service.running:
    - name: Bacula-fd
    - enable: True
    - full_restart: True
    - require:
      - file: install_bacula_fd_win
{% if not salt['file.directory_exists' ]('C:\\Program Files\\Bacula') %}
  cmd.run:
    - name: {{ map.fd.win_scripts }}/bacula_win.exe /S
    - require:
      - file: install_bacula_fd_win
    - require_in:
      - service: install_bacula_fd_win

clean_old_firewall_rules_for_bacula:
  cmd.run:
    - name: 'Netsh.exe advfirewall firewall delete rule name="bacula-fd"'

add_firewall_rule_for_bacula:
  cmd.run:
    - name: 'Netsh.exe advfirewall firewall add rule name="bacula-fd" localport="9102" protocol=tcp dir=in enable=yes action=allow'
    - require:
      - cmd: clean_old_firewall_rules_for_bacula

{% endif %}
