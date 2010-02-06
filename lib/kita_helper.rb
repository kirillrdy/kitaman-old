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


ARCHIVE_EXT=['.tar.bz2','.tar.gz','.tgz','.bz2']


class String

  # Basename that is much smarter that File.basename
  # eg:
  # "mumbo/linux-2.27.5.tar.bz2".smart_basename ==> 'linux'
  def smart_basename
    File.basename(self).slice(0,self.rindex(/-\d/))
  end
 
  # Getting package version number from package URL
  # "http://mom.org/linux-2.26.4.tar.bz2".version ==> '2.26.4'
  def version
    #puts self
    ext = self
    if self.rindex(/-\d/)
      ext = self.slice( self.rindex(/-\d/)+1 ,self.length) 
    end
    for extention in ARCHIVE_EXT
      if ext.index extention
        ext = ext.slice(0,ext.index(extention))
      end
    end
    return ext
  end
end

class Computer

  # Find how many CPU cores host machine has
  def self.number_of_cores
    results = `cat /proc/cpuinfo | grep cores`.scan(/\: (.*?)\n/)
    results ==[] ? 1 : results[0][0].to_i
  end
  
end
