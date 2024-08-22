# Import from jinja
{% from 'vault/map.jinja' import suffix, role_id, secret_id with context %}

handle-zip:
  archive.extracted:
    - name: /usr/local/bin
    - source: 'https://maven.posam.sk/repository/raw-salt/vault/vault_1.16.1_linux_amd64.zip'
    - skip_verify: True
    - archive_format: zip
    - user: root
    - group: root
    - if_missing: /usr/local/bin/vault
    - enforce_toplevel: False

ensure-directory:
  file.directory:
    - name: /etc/vault.d
    - user: root
    - group: root
    - mode: 600

copy-config-file:
  file.managed:
    - name: /etc/vault.d/config.hcl
    - source: salt://vault/config.hcl
    - user: root
    - group: root
    - mode: 600

copy-service-file:
  file.managed:
    - name: /etc/systemd/system/vault-agent.service
    - source: salt://vault/vault-agent.service
    - user: root
    - group: root
    - mode: 600

reload-systemd:
  cmd.run:
    - name: systemctl daemon-reload

copy-template-file:
  file.managed:
    - name: /etc/vault.d/spring-boot-token.ctmpl
    - source: salt://vault/spring-boot-token.ctmpl
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - context:
        suffix: {{ suffix }}

create-pid-file:
  file.managed:
    - name: /tmp/pidfile
    - user: root
    - group: root
    - mode: 600

move-pid-file:
  file.rename:
    - name: /etc/vault.d/pidfile
    - source: /tmp/pidfile
    - force: True

/etc/vault.d/role_id:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - contents: {{ role_id }}
    - replace: True
 
/etc/vault.d/secret_id:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - contents: {{ secret_id }}
    - replace: True

kill-agent:
  service.dead:
    - name: vault-agent
    - require:
      - file: /etc/systemd/system/vault-agent.service
 
start-agent:
  service.running:
    - name: vault-agent
    - enable: True
    - watch:
      - file: /etc/vault.d/config.hcl
      - file: /etc/vault.d/spring-boot-token.ctmpl
      - file: /etc/vault.d/role_id
      - file: /etc/vault.d/secret_id
      - file: /etc/systemd/system/vault-agent.service
