- name: Backup Nameservers
  hosts: nameservers
  vars_files:
    - secrets.yml
  vars:
    s3_bucket: nodemaster
    s3_dest_path: "{{ ansible_hostname }}/bind_backup_{{ ansible_date_time.iso8601 }}.tar.bz2"
    backup_items:
      - /etc/bind
      - /var/lib/bind
    backup_path: /tmp/bind_backup.tar.bz2
    backup_format: bz2
    dbs_to_dump: all
  gather_facts: yes

  tasks:
    - name: Install packages required to connect to S3
      include: tasks/s3_pkgs.yml
      become: yes
      become_user: root

    - name: Prepare backup
      include: tasks/create_tarball.yml
      become: yes
      become_user: root

    - name: Upload to S3
      include: tasks/s3_put.yml

    - name: Remove local files
      include: tasks/unlink_files.yml
      vars:
        rm_files: 
          - "{{ backup_path }}"

# vi:syntax=yaml
