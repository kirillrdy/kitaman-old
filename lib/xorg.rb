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
load 'kitaman/make.rb'


class Kita

  # Generates Build Enviroment for the package
  def build_enviroment
    where_to_cd =  `tar tf #{files_list_local[0]}`.split("\n")[0]
    where_to_cd = where_to_cd.slice(0,where_to_cd.index("/")) if where_to_cd.index('/')
    """
    set -e
    export MAKEFLAGS='-j#{number_of_cores+1}'
    export XORG_CONFIG='--prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var'

    INSTALL_DIR=#{paths[:install_dir]}
    BUILD_DIR=#{KitamanConfig.config['BUILD_DIR']}/#{where_to_cd}
    SRC_DIR=${BUILD_DIR}
  
    mkdir -p #{paths[:install_dir]}

    """
  end


   # Extracts, patches, builds and packs a package
  def build
    
    result = extract
    patch
           
    # build commands here
    result = result and system( build_enviroment  + """
    
    config_src()
    {
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
    """)

    if !result
      return result
    else
      return (result and create_package)
    end
    
  end
end
