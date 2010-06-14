extend PreBaby

def installed?
  File.exists?(LFS+"/dev")
end

def install
  `mkdir -p #{LFS}`
  `
  mkdir -v #{LFS}/dev
  mkdir -v #{LFS}/proc
  mkdir -v #{LFS}/sys
  
  mknod -m 600 #{LFS}/dev/console c 5 1
  mknod -m 666 #{LFS}/dev/null c 1 3
  
  mount -v --bind /dev #{LFS}/dev
  
  mount -vt devpts devpts #{LFS}/dev/pts
  mount -vt tmpfs shm #{LFS}/dev/shm
  mount -vt proc proc #{LFS}/proc
  mount -vt sysfs sysfs #{LFS}/sys
  `
end

chroot . /tools/usr/bin/env -i  HOME=/root TERM="$TERM" PS1='\u:\w\$ '  PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin:/tools/usr/bin /tools/bin/bash --login +h
