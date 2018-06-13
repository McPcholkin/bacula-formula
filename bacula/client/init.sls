{% set os_type_check = salt['grains.get']('os_family') %}
include:
  {% if os_type_check == 'Windows' %}
  - bacula.fd.win_install
  - bacula.client.win_config
  {% else %}
  - bacula.fd.install
  - bacula.client.config
  {% endif %}
