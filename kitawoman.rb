#!/usr/bin/ruby

# If there is a kitaman, there got to be kitawoman.
# Kitaman's job to work on kitafiles, build your system
# Kitawoman's job is to look after the state of kita

new_chroot_dir = "/mnt/pariah"
stage2_file = "/home/kirillvr/Desktop/stage2-x86-2007.0.tar.bz2"
host_src_dir = "/home/kirillvr/Desktop/src"
ruby_tar_file = "/home/kirillvr/Desktop/ruby-1.9.1-preview1.tar.bz2"

# Clean Junk

`
cd #{new_chroot_dir}
umount #{new_chroot_dir}/proc
rm -rf *

tar xjpf #{stage2_file}

tar xjpf #{ruby_tar_file} -C #{new_chroot_dir}/root/
chroot #{new_chroot_dir} 'cd /root/ruby* && ./configure --prefix=/usr && make && make install'

cd /home/kirillvr/Desktop/kitaman
./install.sh #{new_chroot_dir}


cd #{new_chroot_dir}
cp #{host_src_dir}/* #{new_chroot_dir}/usr/kitaman/src/

mount -t proc none proc

`
