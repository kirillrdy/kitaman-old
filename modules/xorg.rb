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

require 'kitaman/kita_helper'
require 'kitaman/kitaman_helper'

module Xorg

   # Extracts, patches, builds and packs a package
  def build
    
    result = extract
    patch
           
    # build commands here
    result = result and system( build_enviroment  + "
    
    config_src()
    {
      ./configure --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var
    }
    
    build_src()
    {  
      make
    }
    
    #{@info["BUILD"]}

    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    config_src > /var/kitaman/config_logs/#{@info['NAME-VER']}
    build_src
    ")

    if !result
      return result
    else
      return (result and create_package)
    end
    
  end
 
  
end
