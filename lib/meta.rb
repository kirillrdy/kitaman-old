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


load 'kitaman/kita_class.rb'

class Kita

  def build
    puts "Nothing to do for meta package"
    return true
  end
  
  def install    
    if not system("""
      

      post_install()
      {
        echo \"no post install\"
      }

      #{@info["BUILD"]}

      post_install
      
      ldconfig

    """)
      return false
    end
    record_installed
    return true
  end
  
  def download
    puts "Nothing to do for meta package"
    return true
  end
  
end
