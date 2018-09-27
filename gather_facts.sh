ansible oracle_database_servers -m setup --tree /tmp/facts
ansible ovm_servers -m setup --tree /tmp/facts
ansible backupservers  -m setup --tree /tmp/facts
ansible oracle_weblogic_servers -m setup --tree /tmp/facts
ansible oracle_webtier_servers -m setup --tree /tmp/facts
ansible mozard_verseon_oracle-text -m setup --tree /tmp/facts

