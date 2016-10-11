#!/bin/sh -x

ssh_username=vagrant
ssh_password=vagrant

sudoers_file="/tmp/${ssh_username}"
echo "Defaults:${ssh_username} !requiretty" > ${sudoers_file}
echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> ${sudoers_file}
echo ${ssh_password} | sudo -S chmod 440 ${sudoers_file}
echo ${ssh_password} | sudo -S chown root:root ${sudoers_file}
echo ${ssh_password} | sudo -S visudo -c -q -f ${sudoers_file}
echo ${ssh_password} | sudo -S mv ${sudoers_file} /etc/sudoers.d

sudo apt-get --assume-yes update

sudo sed -i "s/^#AuthorizedKeysFile/AuthorizedKeysFile/" /etc/ssh/sshd_config
# sudo sed -i "s/^#GSSAPIAuthentication/GSSAPIAuthentication/" /etc/ssh/sshd_config
#
# sudo sed -i "s/^GRUB_HIDDEN_TIMEOUT/#GRUB_HIDDEN_TIMEOUT/" /etc/default/grub
# sudo sed -i "s/^GRUB_HIDDEN_TIMEOUT_QUIET/#GRUB_HIDDEN_TIMEOUT_QUIET/" /etc/default/grub
# sudo sed -i "s/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/" /etc/default/grub
# sudo update-grub

home_dir="/home/${ssh_username}"

ssh_dir="${home_dir}/.ssh"
authorized_keys_dir="${ssh_dir}/authorized_keys"
mkdir -p ${ssh_dir}
chmod 700 ${ssh_dir}
wget --no-check-certificate \
  "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub" \
  -O ${authorized_keys_dir}
chmod 600 ${authorized_keys_dir}
chown -R ${ssh_username} ${ssh_dir}

iso_file="${home_dir}/VBoxGuestAdditions.iso"
mnt_dir=/mnt/
sudo mount -o loop ${iso_file} ${mnt_dir}
sudo /bin/sh "${mnt_dir}/VBoxLinuxAdditions.run"
sudo umount ${mnt_dir}
rm ${iso_file}

# apt-get clean

# dd if=/dev/zero of=/EMPTY bs=1M | true
# rm -f /EMPTY
# sync
