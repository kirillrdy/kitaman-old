#!/usr/bin/ruby

#    Colonel - Kernel Autoconfig builder
#    /-Arrr...-/
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


BLACK_LIST=["IDE"]

class String

  def to_colonel
    self.upcase.gsub(" ","_")
  end
  
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


#kernel_config = IO.read('kernel_config')
for item in list
  puts "For module #{item.bold}"
  puts "        "+`cat kernel_config | grep #{item.white}`.green
end

