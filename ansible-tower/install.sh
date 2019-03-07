cd /opt
tar xvzf ansible-tower-*.tar.gz
cd ansible-tower-setup-bundle*
ansible-playbook -i /opt/inventory install.yml
