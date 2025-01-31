# Table of content

- [Node preparation](#node-preparation)
- [Initializaing K8s cluster](#initializaing-k8s-cluster)
- [Wiki](wiki/main.md)



## Node preparation

To patch SD card for k8s node execute script

```bash
sudo ./prepare_sd_card.sh DEVICE NODE_FUNCTION
```

- `DEVICE` - /dev/mmcblk0
- `NODE_FUNCTION` - one of: master, node1, node2

What script does:
* Download Ubuntu image
* Format SD card
* Copy downloaded .img to card
* Copy cloud image config file to SD card

Example run:

```bash
sudo ./prepare_sd_card.sh /dev/mmcblk0 master
##### Running function: check_sudo #####
OK - running as root

##### Running function: download_img_file #####
The image file already exists at /tmp/ubuntu-24.04.1-preinstalled-server-arm64+raspi.img. No need to download.

##### Running function: format_sd_card #####
Formatting /dev/mmcblk0 as FAT32...
mkfs.fat 4.2 (2021-01-31)
Successfully formatted /dev/mmcblk0 as FAT32.

##### Running function: write_img_to_sd_card #####
Writing /tmp/ubuntu-24.04.1-preinstalled-server-arm64+raspi.img to /dev/mmcblk0...
3644850176 bytes (3,6 GB, 3,4 GiB) copied, 77 s, 47,3 MB/s3675607040 bytes (3,7 GB, 3,4 GiB) copied, 77,8975 s, 47,2 MB/s

876+1 records in
876+1 records out
3675607040 bytes (3,7 GB, 3,4 GiB) copied, 104,268 s, 35,3 MB/s
Successfully wrote /tmp/ubuntu-24.04.1-preinstalled-server-arm64+raspi.img to /dev/mmcblk0.

##### Running function: cloud_init #####
Creating SSH configuration...
Copying cloud-config/ubuntu/k8s-master-cloud-config.yml file
```

## Initializaing K8s cluster

- install Ansible collections && Python Bitwaden libraries

```bash
cd ansible && \
ansible-galaxy collection install -r requirments.yml
``` 

To create K8s cluster on previously prepared nodes just run Ansible playbook

```bash
cd ansible && \
ansible-playbok -i inventory bootstrap.yml
```
