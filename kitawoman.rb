#!/usr/bin/ruby

#########################################################################################
# If there is a kitaman, there got to be kitawoman.
# Kitaman's job to work on kitafiles, build your system
# Kitawoman's job is to do all the house work, look after the state of kitaworld
# Written by Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
# Silverpond Pty Ltd
# 2009
#########################################################################################

WORK_DIR = "/mnt/pariah2"
STAGE2_FILE = "/home/kirillvr/Desktop/stage2-x86-2007.0.tar.bz2"
SRC_CACHE_DIR = "/home/kirillvr/Desktop/src"
RUBY_SRC_PATH = "/home/kirillvr/Desktop/ruby-1.9.1-preview1.tar.bz2"
KITMAN_GIT_REPO= 'git@github.com:kirillrdy/kitaman.git'

def clean_working_dir
`
  cd #{WORK_DIR}
  umount #{WORK_DIR}/proc
  rm -rf *
`
end

def compile_ruby
  `
  cd #{WORK_DIR}
  tar xjpf #{RUBY_SRC_PATH} -C #{WORK_DIR}/root/
  chroot #{WORK_DIR} '/bin/bash cd /root/ruby* && ./configure --prefix=/usr && make && make install'
  ` 
end

def prepare_new_chroot
`
cd #{WORK_DIR}
tar xjpf #{STAGE2_FILE}
mount -t proc none proc
mkdir -p #{WORK_DIR}/usr/kitaman/src
cp #{SRC_CACHE_DIR}/* #{WORK_DIR}/usr/kitaman/src/
`
end

def install_kitaman
`
  cd /tmp
  git clone #{KITMAN_GIT_REPO}
  cd kitaman
  ./install.sh #{WORK_DIR}
`
end


#################################################################################
# Entry Point
#################################################################################


clean_working_dir
prepare_new_chroot
install_kitaman
compile_ruby
