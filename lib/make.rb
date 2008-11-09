# This is the base class for Kita, all classes shall inherit from this class !

require 'lib/kita_helper'
require 'lib/kitaman_helper'
require 'lib/kita_class'

class Kita

  def paths
    paths = {}
    paths[:tar_bin_file] = KitamanConfig.config['PKG_DIR']+'/'+@info['NAME-VER']+'-bin.tar.bz2'
    paths[:install_dir] = KitamanConfig.config['FAKE_INSTALL_DIR']+'/'+@info["NAME-VER"]  
    paths[:state_file]= KitamanConfig.config['STATE_DIR']+'/'+@info['NAME-VER']

    return paths
  end

  def build_enviroment
    where_to_cd =  `tar tf #{files_list_local[0]}`.split("\n")[0]
    """
    export MAKEFLAGS='-j4'
    INSTALL_DIR=#{paths[:install_dir]}
    BUILD_DIR=#{KitamanConfig.config['BUILD_DIR']}/#{where_to_cd}
    SRC_DIR=#{KitamanConfig.config['SRC_DIR']}
    
    cd ${BUILD_DIR}
    """
  end

  def record_installed
    `tar tf #{paths[:tar_bin_file]} > #{paths[:state_file]}`
  end

  def build
    
    extract
    patch

        
    # build commands here
    Kernel.system( build_enviroment  + """
    
    build_src()
    {
      ./configure --prefix=/usr
      make
    }
   #{@info["BUILD"]}

    build_src
    """)

    create_package

  end

  def patch
    for file in files_list_local
      if file.index('.patch')
        file = File.basename(file)
        `cd #{KitamanConfig.config['BUILD_DIR']} && patch -Np1 -i #{KitamanConfig.config['SRC_DIR']}/#{file}`
      end
    end
  end

  def extract
    for file in files_list_local
      `tar xjpf #{file} -C #{KitamanConfig.config['BUILD_DIR']}/` if file.index('.tar.bz2')      
      `tar xpf #{file} -C #{KitamanConfig.config['BUILD_DIR']}/` if file.index('.tar.gz')      
    end
  end

  def install
    
    #`tar xjpf `  
    record_installed 
  end

  def create_package
     Kernel.system( build_enviroment  + """
    
   kita_install()
    {
      make DESTDIR=$INSTALL_DIR install
      #make install
    }

    #{@info["BUILD"]}

    kita_install
    cd $INSTALL_DIR

    tar cjpf #{paths[:tar_bin_file]} *

    """)

  end

end
