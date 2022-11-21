#!/usr/bin/env bash
# $1 mode [manager, worker]
if [ ! -z $1 ];then
    if [ $1 == 'manager' ] || [ $1 == 'worker' ];then
        sudo apt update
        sudo apt upgrade
        sudo apt install sshpass openmpi-bin openmpi-common openmpi-doc libopenmpi-dev python3-pip -y
        echo 'installing mpi4py'
        python -m pip install --upgrade pip
        sudo pip install mpi4py
        echo 'setting ssh'
        ssh-keygen -t rsa # no usar frase
        cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
        eval `ssh-agent`
        sshpass -v -p 'raspberry' ssh-add # -P para frase, -p para passwd
        if [ $1 == 'manager' ];then
            echo 'installing nfs-kernel-server for manager'
            sudo apt install nfs-kernel-server -y
            sshpass -v -p 'raspberry' ssh-copy-id pi2@rlabred001.local
            sshpass -v -p 'raspberry' ssh-copy-id pi2@rlabred001.local
            sshpass -v -p 'raspberry' ssh-copy-id pi2@rlabred001.local
            echo 'setting shared directory for manager'
            mkdir -p $HOME/mpi-drive
            sudo su -c "echo '$HOME/mpi-drive *(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports"
            sudo service nfs-kernel-server restart
        elif [ $1 == 'worker' ];then
            echo 'sending passwd to manager'
            sshpass -v -p 'raspberry' ssh-copy-id pi2@rlabred001.local
            echo 'installing nfs-common for worker'
            sudo apt install nfs-common -y
            echo 'setting shared directory for worker'
            mkdir -p $HOME/mpi-drive
            sudo mount -t nfs rlabred001.local:/home/pi2/mpi-drive $HOME/mpi-drive
            sudo su -c "echo 'rlabred001.local:/home/pi2/mpi-drive $HOME/mpi-drive nfs' >> /etc/fstab"
        fi
    fi
else
    echo 'Provide an option: manager or worker'
fi