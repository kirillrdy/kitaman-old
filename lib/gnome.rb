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

  def create_package
     system( build_enviroment  + """
    
   kita_install()
    {
      make DESTDIR=$INSTALL_DIR install
      
      #next line is vital for building Gnome Apps
      #this is actually because I dont know how to install schema files properly, so I have to rely on gnome build scripts
      make install
    }

    #{@info["BUILD"]}
    
    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    kita_install
    cd $INSTALL_DIR

    tar cjpf #{paths[:tar_bin_file]} *

    """)

  end

private

def kitaman_post_install
    """
      # Update the linkers cache
      ldconfig
      
      update-desktop-database
      update-mime-database -V /usr/share/mime

      for i in /usr/share/icons/*/ ; do    
        gtk-update-icon-cache -ft $i
      done
      
      echo \"Cleaning up\"
      rm -rf $BUILD_DIR
      rm -rf $INSTALL_DIR
    """
end

end
