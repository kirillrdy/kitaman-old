#!/usr/bin/ruby

#    Kitaman - Software Project Manager
#    /-Promise to a little girl and a big world-/
#
#    Copyright (C) 2009  Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

################################################################################
# If there is a kitaman, there got to be kitawoman.
# Kitaman's job to work on kitafiles, build your system
# Kitawoman's job is to do all the house work, look after the state of kitaworld
# Written by Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
# Silverpond Pty Ltd
# 2009
################################################################################

WORK_DIR = "/mnt/pariah"
STAGE2_FILE = "/home/kirillvr/Desktop/stage2-x86-2007.0.tar.bz2"
SRC_CACHE_DIR = "/home/kirillvr/Desktop/src"
RUBY_SRC_PATH = "/home/kirillvr/Desktop/ruby-1.9.1-p0.tar.bz2"
KITMAN_GIT_REPO= 'git@kita-linux.org:kitaman.git'

def clean_working_dir
`
  mkdir -p #{WORK_DIR}
  cd #{WORK_DIR}

  umount #{WORK_DIR}/proc
  rm -rf *
`
end

def compile_ruby
  `
  cd #{WORK_DIR}
  tar xjpf #{RUBY_SRC_PATH} -C #{WORK_DIR}/root/
  cp /home/kirillvr/Desktop/kitaman/build_ruby.sh #{WORK_DIR}/root
  `
  `chroot #{WORK_DIR} /root/build_ruby.sh`
  #chroot #{WORK_DIR} '/bin/bash cd /root/ruby* && ./configure --prefix=/usr && make && make install'
   
end

def prepare_new_chroot
`
cd #{WORK_DIR}
tar xjpf #{STAGE2_FILE}
mount -t proc none proc
cp /etc/resolv.conf #{WORK_DIR}/etc
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

puts "Cleaning Working Directory"
clean_working_dir

puts "Preparing new Chroot"
prepare_new_chroot

puts "Installing Kitaman"
install_kitaman

puts "Compiling Ruby"
compile_ruby
