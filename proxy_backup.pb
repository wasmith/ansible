- name: Backup Cloud Proxy
  hosts: proxies
  vars_files:
    - secrets.yml
  vars:
    s3_bucket: nodemaster
    s3_dest_path: "{{ ansible_hostname }}/nginx_backup_{{ ansible_date_time.iso8601 }}.tar.bz2"
    backup_items:
      - /etc/nginx
    backup_path: /tmp/nginx_backup.tar.bz2
    backup_format: bz2
  gather_facts: yes

  tasks:
    - name: Install packages required to connect to S3
      include: tasks/s3_pkgs.yml

    - name: Prepare backup
      include: tasks/create_tarball.yml

    - name: Upload to S3
      include: tasks/s3_put.yml

    - name: Remove local tarball
      file:
        path: "{{ backup_path }}"
        state: absent

# vi:syntax=yaml
