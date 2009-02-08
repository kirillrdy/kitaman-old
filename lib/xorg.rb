# This class adds support for building make driven packages

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
    
    build_src()
    {
      ./configure $XORG_CONFIG
      make
    }
    
    #{@info["BUILD"]}

    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    build_src
    """)

    if !result
      return result
    else
      return (result and create_package)
    end
    
  end

end
