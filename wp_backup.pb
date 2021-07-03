- name: Backup SGFE Wordpress
  hosts: sgfe_wordpress_prod
  vars_files:
    - secrets.yml
  vars:
    s3_bucket: nodemaster
    s3_dest_path: "{{ ansible_hostname }}/wordpress_backup_{{ ansible_date_time.iso8601 }}.tar.bz2"
    db_dump_path: "/tmp/db_{{ ansible_hostname }}.sql"
    wp_home: "/home/sgfe/www-root"
    backup_path: /tmp/sgfe_wp_backup.tar.bz2
    backup_format: bz2
    dbs_to_dump: all
  gather_facts: yes

  tasks:
    - name: Install required packages for dumping SQL databases 
      include: tasks/sqldump_pkgs.pb

    - name: Install packages required to connect to S3
      include: tasks/s3_pkgs.yml

    - name: Backup Databases
      include: tasks/dump_maria.yml

    - name: Prepare backup
      include: tasks/create_tarball.yml
      vars:
        backup_items:
          - "{{ wp_home }}"
          - "{{ db_dump_path }}"
          - /etc/nginx

    - name: Upload to S3
      include: tasks/s3_put.yml

    - name: Remove local files
      include: tasks/unlink_files.yml
      vars:
        rm_files: 
          - "{{ backup_path }}"
          - "{{ db_dump_path }}"


# vi:syntax=yaml
