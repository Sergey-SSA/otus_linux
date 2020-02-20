# Otus-linux Hometask
## Less3 additional hometask *
### Установка btrfs
btrfs будем устанавливать на доступные диски - sdb,sdc,sdd,sde
выводим список:
``` 
[vagrant@lvm ~]$ lsblk

NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 
```
Создаем ФС на дисках sdb,sdc,sdd,sde.
```
[root@lvm vagrant]# mkfs.btrfs /dev/sdb
btrfs-progs v4.9.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               a8383377-ba69-40fe-b6c0-c0c862eed531
Node size:          16384
Sector size:        4096
Filesystem size:    10.00GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP               1.00GiB
  System:           DUP               8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1    10.00GiB  /dev/sdb

[root@lvm vagrant]# mkfs.btrfs /dev/sdc /dev/sdd
btrfs-progs v4.9.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               38f786d4-c0b5-40eb-977b-d957bbebad5d
Node size:          16384
Sector size:        4096
Filesystem size:    3.00GiB
Block group profiles:
  Data:             RAID0           307.12MiB
  Metadata:         RAID1           153.56MiB
  System:           RAID1             8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  2
Devices:
   ID        SIZE  PATH
    1     2.00GiB  /dev/sdc
    2     1.00GiB  /dev/sdd
```
Создаем папку и монтируем первый том
```
[root@lvm vagrant]# mkdir /mnt/sdb
[root@lvm vagrant]# mount /dev/sdb/ /mnt/sdb/
[root@lvm vagrant]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00   38G  760M   37G   2% /
devtmpfs                         109M     0  109M   0% /dev
tmpfs                            118M     0  118M   0% /dev/shm
tmpfs                            118M  4.5M  114M   4% /run
tmpfs                            118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                       1014M   63M  952M   7% /boot
tmpfs                             24M     0   24M   0% /run/user/1000
/dev/sdb                          10G   17M  8.0G   1% /mnt/sdb
```
В результате видим появившийся смонтированый раздел равный 8Гб.
Расширим созданый раздел средствами btrfs, добавив еще один диск размером 2Гб
```
[root@lvm vagrant]# btrfs devicce add /dev/sdc/ /mnt/sdb/
[root@lvm vagrant]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00   38G  760M   37G   2% /
devtmpfs                         109M     0  109M   0% /dev
tmpfs                            118M     0  118M   0% /dev/shm
tmpfs                            118M  4.5M  114M   4% /run
tmpfs                            118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                       1014M   63M  952M   7% /boot
tmpfs                             24M     0   24M   0% /run/user/1000
/dev/sdb                          12G   17M   10G   1% /mnt/sdb
```
Как результат видим что размер примонтированого тома увеличился до 10ГБ
```
[root@lvm vagrant]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk /mnt/sdb
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 
```
Просмотрим статус смонтированого ресурса
```
[root@lvm vagrant]# btrfs devce stats /mnt/sdb/
[/dev/sdb].write_io_errs    0
[/dev/sdb].read_io_errs     0
[/dev/sdb].flush_io_errs    0
[/dev/sdb].corruption_errs  0
[/dev/sdb].generation_errs  0
[/dev/sdc].write_io_errs    0
[/dev/sdc].read_io_errs     0
[/dev/sdc].flush_io_errs    0
[/dev/sdc].corruption_errs  0
[/dev/sdc].generation_errs  0

[root@lvm vagrant]# btrfs filesystem show --mounted
Label: none  uuid: a8383377-ba69-40fe-b6c0-c0c862eed531
	Total devices 2 FS bytes used 384.00KiB
	devid    1 size 10.00GiB used 2.02GiB path /dev/sdb
	devid    2 size 2.00GiB used 0.00B path /dev/sdc
```
Перенесем на смонтированый раздел папку /vat/opt

```	
[root@lvm vagrant]# mount /dev/sdb /var/opt/ 
[root@lvm vagrant]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00   38G  760M   37G   2% /
devtmpfs                         109M     0  109M   0% /dev
tmpfs                            118M     0  118M   0% /dev/shm
tmpfs                            118M  4.5M  114M   4% /run
tmpfs                            118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                       1014M   63M  952M   7% /boot
tmpfs                             24M     0   24M   0% /run/user/1000
/dev/sdb                          12G   17M   10G   1% /var/opt
```
Перейдем в папку и для наглядности создадим файлы
```
[root@lvm opt]# cd opt/
[root@lvm opt]# ll
total 0
[root@lvm opt]# touch file{1..20}
[root@lvm opt]# ll
total 0
-rw-r--r--. 1 root root 0 Feb 19 11:10 file1
-rw-r--r--. 1 root root 0 Feb 19 11:10 file10
-rw-r--r--. 1 root root 0 Feb 19 11:10 file11
-rw-r--r--. 1 root root 0 Feb 19 11:10 file12
-rw-r--r--. 1 root root 0 Feb 19 11:10 file13
-rw-r--r--. 1 root root 0 Feb 19 11:10 file14
-rw-r--r--. 1 root root 0 Feb 19 11:10 file15
-rw-r--r--. 1 root root 0 Feb 19 11:10 file16
-rw-r--r--. 1 root root 0 Feb 19 11:10 file17
-rw-r--r--. 1 root root 0 Feb 19 11:10 file18
-rw-r--r--. 1 root root 0 Feb 19 11:10 file19
-rw-r--r--. 1 root root 0 Feb 19 11:10 file2
-rw-r--r--. 1 root root 0 Feb 19 11:10 file20
-rw-r--r--. 1 root root 0 Feb 19 11:10 file3
-rw-r--r--. 1 root root 0 Feb 19 11:10 file4
-rw-r--r--. 1 root root 0 Feb 19 11:10 file5
-rw-r--r--. 1 root root 0 Feb 19 11:10 file6
-rw-r--r--. 1 root root 0 Feb 19 11:10 file7
-rw-r--r--. 1 root root 0 Feb 19 11:10 file8
-rw-r--r--. 1 root root 0 Feb 19 11:10 file9

[root@lvm opt]# lslsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
├─sda1                    8:1    0    1M  0 part 
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk /var/opt
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 
```
