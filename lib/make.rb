# This class adds support for building make driven packages

require 'kitaman/kita_helper'
require 'kitaman/kitaman_helper'
load 'kitaman/kita_class.rb'


class Kita

  # shortcuts for all important paths that are use often
  def paths
    paths = {}
    paths[:tar_bin_file] = KitamanConfig.config['PKG_DIR']+'/'+@info['NAME-VER']+'-bin.tar.bz2'
    paths[:install_dir] = KitamanConfig.config['FAKE_INSTALL_DIR']+'/'+@info["NAME-VER"]  
    paths[:state_file]= KitamanConfig.config['STATE_DIR']+'/'+@info['NAME-VER']
    return paths
  end

  # Generates Build Enviroment for the package
  def build_enviroment
    where_to_cd =  `tar tf #{files_list_local[0]}`.split("\n")[0]
    where_to_cd = where_to_cd.slice(0,where_to_cd.index("/")) if where_to_cd.index('/')
    """
    set -e
    export MAKEFLAGS='-j#{number_of_cores+1}'
    INSTALL_DIR=#{paths[:install_dir]}
    BUILD_DIR=#{KitamanConfig.config['BUILD_DIR']}/#{where_to_cd}
    SRC_DIR=${BUILD_DIR}
  
    mkdir -p #{paths[:install_dir]}

    """
  end

  # Records package as installed and records a list of all files installed by the package
  def record_installed
    `tar tf #{paths[:tar_bin_file]} > #{paths[:state_file]}`
  end


  # Extracts, patches, builds and packs a package
  def build
    
    result = extract
    patch
           
    # build commands here
    result = result and system( build_enviroment  + """
    
    build_src()
    {
      ./configure --prefix=/usr
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

  # Patch source code
  def patch    
    for file in files_list_local
      if file.index('.patch')
        file = File.basename(file)
        `cd #{KitamanConfig.config['BUILD_DIR']} && patch -Np1 -i #{KitamanConfig.config['SRC_DIR']}/#{file}`
      end
    end
  end

  # Extract source code
  def extract
    result = true
    for file in files_list_local
      result = (result and system("tar xjpf #{file} -C #{KitamanConfig.config['BUILD_DIR']}/")) if file.index('.tar.bz2')
      result = (result and system("tar xpf #{file} -C #{KitamanConfig.config['BUILD_DIR']}/")) if file.index('.tar.gz')
      result = (result and system("tar xpf #{file} -C #{KitamanConfig.config['BUILD_DIR']}/")) if file.index('.tgz')
      result = (result and system("tar #{file} -d #{KitamanConfig.config['BUILD_DIR']}/")) if file.index('.zip')
    end
    return result
  end

  def install
    if not system(build_enviroment + """
      
      tar xjpf #{paths[:tar_bin_file]} -C /

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
  
  # Generates tar ball with binary files
  def create_package
     system( build_enviroment  + """
    
   kita_install()
    {
      make DESTDIR=$INSTALL_DIR install
      #make install
    }

    #{@info["BUILD"]}
    
    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    kita_install
    cd $INSTALL_DIR

    tar cjpf #{paths[:tar_bin_file]} *

    """)

  end

end
