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

#########################################################################################
# If there is a kitaman, there got to be kitawoman.
# Kitaman's job to work on kitafiles, build your system
# Kitawoman's job is to do all the house work, look after the state of kitaworld
# Written by Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
# Silverpond Pty Ltd
# 2009
#########################################################################################
#
#                         :xkkko;          .';;.                                                            
#                        ,kkkOOOOO.      .okkkkO,                                                           
#                        oO000KKKNdcodo;,O000000o                                                           
#                        xKXXNNWWMNNNNNNNWWNNXXXo                                                           
#                        oNWW0xo:;,'..';cokKWMWW;                           ..';........                    
#                        'l.                 'lk                       .....    ....   .'...                
#                     ...                       ..                  ...              ....   ...             
#                    ..                           .'               ,.                   .,:,.  ..           
#                   ,                              .;            .c'...                    .;,   '.         
#                  '                               .:,          .dlc:,'.                          '         
#                  ,                             ..':d          lxxdlc;'..                         ,        
#                 .,.......''','.     ..'.''......';ck'        .K0Okxoc;,.......'....      .....   ;        
#                 ',......';::;.........,;:,....',;cdOc        ,NNXKOkdl:;,'....;::,........:::'...;.       
#                 .l;;;;;,,,,,,,,,'''',,,,,,,,;;:coxOXc        ;MMWNXKOxdlc:;;,,,,,,,'''''',,,,,,,,l        
#                  lllllcccccccc::::::::cccccclloxkKXW,        .MMMMWNXKOkdollccccc::::;::::cccccco,        
#                  'xdddddoooooollcccclloodddddxO0XWMX          OMMMMMWNXKOkxddddooolcccclloooooox;         
#                   :kkkkkxxdxO0kddooodxO00xxkOKXWMMW,          .XMMMMMMWNXK0kxdOKOkddoodkOOxdxkx.          
#                    'kOkOOOOkxk000KK0000OkO0KXXWMMO.             dMMMMMMWNXKK00kO0K00OO0OkxkkOc            
#                      dkkkkO00KXNXK0KNWNXKK0KKNMMK                OWMMMMNXK0000KXNNNKKXXK0Okk'             
#                     ,;codkOOO0000KKK0000000KKXNN0o.            .ok0XNNNXK000OOOOOOOOOOOOkkxo.             
#                    ;'cllldxxxxxxxxxxxxkkkkkOOKNN0kx'          .xxk0NWNK0Okxxxxddddddddddolxc:.            
#                   ;:xKNd,;;::ccccccccccccccloxXWWXOd          l00XNWMXOxdollcccccccccc:::;XXx'            
#                   .dko,:..''',,,,,,,,,,,,,,;:lk.,ll.           ::..WN0xolc::::;;;;;;;;;,,':'.             
#                       ,.........''''''''''',,:lo                  'X0kdlc:;;;;;,,,,,,,,,'',               
#                      ., ...................'',:o;                 :0Oxoc:;;,,,,,,,,,,''''.,               
#                      ,  .....................',:d.                oOkdlc;;,,,,,,,''''''''.;               
#                     ..  ......................';cl                kkxol:;,,,,,''''''''''..:               
#                     ,   .......................,;o'              .Oxdlc;,,,'''''''''''''..,.              
#                    '.  ........................',:o              ;xxol:;,'''''',,,,,'''....,              
#                    , ..........................',:d.             :xdoc:,,'''',,;:c:;,,''...,              
#                    :,......................'',:llc:.           ..'kkdl:;,,,,;cdOKXKkoc:;,,;,              
#                     .;xdoolllllllllloooddddxxk0Xdc;,'..........',co0NX0kxdxOKWMMMMMMNX0Okxl..             
#                   .':oOXK000KNWMMMMMMMMMWNXXNWMN0xl:;''.........',:lxOKXNNNNXXXKKKK0000Oxl:,..            
#                  ..,:ok0XNWWWWWWWWWWWWWNNNXXK0kdl:;,'..................',,,,;;;;;,,,''......              
#                   ....',;::cccllllllllcc::;;,,'.......                                                    
#                            .................                                                              
#



WORK_DIR = "/mnt/pariah"
STAGE2_FILE = "/home/kirillvr/Desktop/stage2-x86-2007.0.tar.bz2"
SRC_CACHE_DIR = "/home/kirillvr/Desktop/src"

class Kitababy
  attr :commit
  attr :root_dir
  
  def initialize(commit)
    @commit = commit
    date =`date +%Y%m%d`.delete "\n" 
    @root_dir = "#{WORK_DIR}/#{date}-#{@commit}" 
  end

  def mark_complete
    `touch #{@WORK_DIR}/#{@commit}`
  end

  def setup?
    File.exists?("#{@root_dir}")
  end

  def complite?
    File.exists?("#{WORK_DIR}/#{@commit}")
  end


 def clean_working_dir
  `
    mkdir -p #{@root_dir}
    cd #{@root_dir}

    umount #{@root_dir}/proc
    rm -rf *
  `
  end

  def install_kitaman
  `
    cd #{WORK_DIR}/kitaman
    rake kitaman:install['#{@root_dir}']
  `
  end


  def install_ruby
    system("export KITAMAN_INSTALL_PREFIX=#{@root_dir} && kitaman -qf glibc ruby")
  end

  def prepare_new_chroot
  `
  cd #{@root_dir}
  tar xjpf #{STAGE2_FILE}
  mount -t proc none proc
  cp /etc/resolv.conf #{@root_dir}/etc
  mkdir -p #{@root_dir}/usr/kitaman/src
  cp #{SRC_CACHE_DIR}/* #{@root_dir}/usr/kitaman/src/
  `
  end


end



class Kitawoman

  def get_latest_commit(repo = "#{WORK_DIR}/kitaman")
    `cd #{repo} && git show`.scan(/commit (.*?)\n/)[0][0]
  end


  def execute_in_chroot(dir,string)
    `cat > #{dir}/tmp/script.sh  << EOF
  #!/bin/bash
  #{string}
    `
    `chmod +x #{dir}/tmp/script.sh`
    `chroot #{dir} /tmp/script.sh`
  end

  def execute_actions(kita_baby)
    actions = [:clean_working_dir,:prepare_new_chroot,:install_ruby,:install_kitaman]

    for action in actions
      puts action
      kita_baby.send action
    end
  end
 
  def Kitawoman.get_latest_kitaman
    if File.exists? "#{WORK_DIR}/kitaman"
      system("cd #{WORK_DIR}/kitaman && git pull")
    else
      system("cd #{WORK_DIR} && git clone git@kita-linux.org:kitaman.git")
    end
    
  end

end



#################################################################################
# Entry Point
#################################################################################

#clean_working_dir

#prepare_new_chroot

#install_kitaman

#install_ruby


kitawoman = Kitawoman.new
Kitawoman.get_latest_kitaman

baby = Kitababy.new(kitawoman.get_latest_commit)

kitawoman.execute_actions(baby) if not baby.setup?


kitawoman.execute_in_chroot(baby.root_dir,'kitaman -q base')
kitawoman.execute_in_chroot(baby.root_dir,'kitaman -q xorg')
kitawoman.execute_in_chroot(baby.root_dir,'kitaman -q kita-developer')
