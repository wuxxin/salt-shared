setup harddisk storage
======================

Features:
 * (gpt/mbr) partition creation
 * mdadm creation
 * lvm creation
 * format partitions
 * mount partitions
 * mount swap
 * skeleton directory creation
 * relocate data and make a symlink from old location to new location

callable via:

{% from 'experiment/storage/lib.sls' import storage_setup with context %}
{{ storage_setup(data) }}

sample data: example.pillar

