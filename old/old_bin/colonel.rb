#!/usr/bin/ruby

#    Colonel - Kernel Autoconfig builder
#    /-Arrr...-/
#
#    Copyright (C) 2011  Kirill Radzikhovskyy <kirillrdy@kita-linux.org>
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

require 'kitaman/kitaman_helper'

# the so called black list needs to be investigated
# this is caused by lspci and kernel config having different names for module (sometimes)
kernel_config_file_location = '/usr/src/linux/arch/x86/configs/i386_defconfig'
BLACK_LIST=["IDE"]


# here is a list of always build modules, like filesystems etc
ALWAYS_INSTALL=['REISERFS_FS',
                'EXT4_FS',
                'CONFIG_UDF_FS',
                'CONFIG_FUSION',
                'CONFIG_BLK_DEV_IDECD']

class String

  # "dhcio ide".to_colonel == "DHCIO_IDE"
  def to_colonel
    self.upcase.gsub(" ","_")
  end
  
  # removes items from black list and return remaining
  # "ATIIXP_IDE".white => "ATIIXP" , because kernel doesnt have ATIIXP_IDE_CONFIG
  def white
    temp = self
    for black_item in BLACK_LIST
      temp.gsub!("_"+black_item,"")
    end  
  temp
  end
  
end

list = `lspci -k | grep Kernel`.scan(/(?:.*?)use: (.*?)\n/)

# filter and clean the list
list.map! {|x| x[0]}
list.uniq!
list.map! {|x| x.to_colonel}

list += ALWAYS_INSTALL


##### this loop is soooo ugly....
# in future, needs to be changed
# but for now,will do

# For each found hardware piece
for item in list
  
  #for each module in kernel that corresponds to our hardware item
  for part in `cat #{kernel_config_file_location} | grep #{item.white}`.split('\n')
  
    # if the item is not set
    if not (/=y/ === part)
      puts part
      on_setting = part.scan(/ (.*?) is not set\n/)
      
      #for each found setting, lets turn it on and write to config file
      for on in on_setting        
        to_write = on[0]+'=y'
        `echo #{to_write} >> #{kernel_config_file_location}`
      end
    end
  end
end

