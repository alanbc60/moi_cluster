#!/usr/bin/env bash
# $1 mode [manager, worker]
manager_ip=172.30.2.1
worker1_ip=172.30.2.2
worker2_ip=172.30.2.3
worker3_ip=172.30.2.4
manager_name=rlabred001
worker1_name=rlabred002
worker2_name=rlabred003
worker3_name=rlabred004
if [ ! -z $1 ];then
    if [ $1 == 'manager' ] || [ $1 == 'worker' ];then
        sudo apt update
        sudo apt upgrade -y
        sudo apt install sshpass openmpi-bin openmpi-common openmpi-doc libopenmpi-dev python3-pip vim zsh git -y
        echo 'installing mpi4py'
        python -m pip install --upgrade pip
        sudo pip install mpi4py
        echo 'setting ssh'
        < /dev/zero ssh-keygen -q -t rsa -N '' >/dev/null
        cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
        if [ $1 == 'manager' ];then
            echo 'configuring hosts file'
            sudo su -c "echo -e '$worker1_ip\t$worker1_name' >> /etc/hosts"
            sudo su -c "echo -e '$worker2_ip\t$worker2_name' >> /etc/hosts"
            sudo su -c "echo -e '$worker3_ip\t$worker3_name' >> /etc/hosts"
            echo 'installing nfs-kernel-server for manager_ip'
            sudo apt install nfs-kernel-server -y
            sshpass -v -p 'raspberry' ssh-copy-id -o StrictHostKeyChecking=no pi2@$worker1_ip
            sshpass -v -p 'raspberry' ssh-copy-id -o StrictHostKeyChecking=no pi2@$worker2_ip
            sshpass -v -p 'raspberry' ssh-copy-id -o StrictHostKeyChecking=no pi2@$worker3_ip
            echo 'setting shared directory for manager_ip'
            mkdir -p $HOME/mpi-drive
            sudo su -c "echo '$HOME/mpi-drive *(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports"
            sudo service nfs-kernel-server restart
            echo 'testing ssh connection'
            ssh -o StrictHostKeyChecking=no $worker1_name 'echo "hello from $HOST"'
            ssh -o StrictHostKeyChecking=no $worker2_name 'echo "hello from $HOST"'
            ssh -o StrictHostKeyChecking=no $worker3_name 'echo "hello from $HOST"'
        elif [ $1 == 'worker' ];then
            echo 'configuring hosts file'
            sudo su -c "echo -e '$manager_ip\t$manager_name' >> /etc/hosts"
            echo 'sending passwd to manager_ip'
            sshpass -v -p 'raspberry' ssh-copy-id -o StrictHostKeyChecking=no pi2@$manager_ip
            echo 'installing nfs-common for worker'
            sudo apt install nfs-common -y
            echo 'setting shared directory for worker'
            mkdir -p $HOME/mpi-drive
            sudo mount -t nfs $manager_ip:/home/pi2/mpi-drive $HOME/mpi-drive
            sudo su -c "echo '$manager_ip:/home/pi2/mpi-drive $HOME/mpi-drive nfs' >> /etc/fstab"
            echo 'testing ssh connection'
            ssh -o StrictHostKeyChecking=no $manager_name 'echo "hello from $HOST"'
        fi
    fi
else
    echo 'Provide an option: manager or worker'
fi

This line does not apper here