#    Kitaman - Software Package Manager
#    /-Promise to a little girl and a big world-/
#
#    Copyright (C) 2010  Kirill Radzikhovskyy <kirillrdy@silverpond.com.au>
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


# TODO Document our most important module

module Kitaman::Package::Make
  include Kitaman

  ####################################
  # Methods that return Strings 
  # They should be overwritten by kitafiles
  #

  # Generates Build Enviroment for the package
  def build_enviroment
    "
    set -e
    export MAKEFLAGS='-j#{Computer.number_of_cores+1}'
    INSTALL_DIR=#{install_dir}
    BUILD_DIR=#{build_dir}
  
    mkdir -p #{install_dir}
    cd #{build_dir}

    "
  end

  # Confugure package
  def config
    "./configure --prefix=#{@install_prefix}"
  end

  # Extracts, patches, builds and packs a package
  def build
    "
    make
    "
  end

  def kita_install
    "
    make DESTDIR=#{install_dir} install
    "
  end

  def post_install
    "echo 'nothing here'"
  end
  
  def clean_up
    "
      # Update the linkers cache
      ldconfig
      echo 'Cleaning up'
      rm -rf #{build_dir}
      rm -rf #{install_dir}
      rm #{tar_bin_file}
    "
  end
  
  #
  # End of String methods
  ########################################

  # Extract source code
  def extract
    result = true
    
    puts "Extrating..."
    for file in files_list_local
      result = (result && Shell::execute("tar xjpf #{file} -C #{Config::BUILD_DIR}/")) if ( file.index('.tar.bz2') || file.index('.bz2') )
      result = (result && Shell::execute("tar xpf #{file} -C #{Config::BUILD_DIR}/")) if ( file.index('.tar.gz') || file.index('.tgz'))
      result = (result && Shell::execute("tar #{file} -d #{Config::BUILD_DIR}/")) if file.index('.zip')
    end
    return result
  end

  # Patch source code
  def patch
    result = true
    
    
    for file in files_list_local
      if file.index('.patch')
        puts "Patching..."
        file = File.basename(file)
        puts "Patching using #{file}".red
        result = result && Shell::execute(build_enviroment + "cd #{build_dir} && patch -Np1 -i #{Config::SRC_DIR}/#{file}")
      end
    end
    return result
  end


  def install

    result = true
    # ruby

    result = result && extract

    #ruby
    result = result && patch


    result = result && Shell::execute("
      
      #{build_enviroment}

      #{config}

      #{build}

      #{kita_install}
          ") #config_src &> /var/kitaman/config_logs/#{self.to_s}

    result = result && create_package
    
    # This is an actual installing
    result = result && Shell::execute(build_enviroment + "tar xjpf #{tar_bin_file} -C #{ENV['Config::INSTALL_PREFIX']}/")

    #TODO FIX 
    result = result && Shell::execute("
    #{post_install}
    #{clean_up}
    ")

    record_installed

    return result
  end


  # Generates tar ball with binary files
  # Those binary files can later be reused
  # They contain all files that belong to the package
  def create_package
    Shell::execute( build_enviroment  + "
    cd #{install_dir}
    tar cjpf #{tar_bin_file} *
    ")
  end
  

  # Records package as installed and records a list of all files installed by the package
  def record_installed
    Shell::execute("tar tf #{tar_bin_file} > #{state_file}")
  end

  ##########################################################################
  private
  ##########################################################################
  
  # Helper that shows where source will be built
  # eg /var/kitaman/build/linux-2.6.26/
  def build_dir
    #use instance var as a cache
    @build_dir ||=  Config::BUILD_DIR + '/' + (`tar tf #{files_list_local.first}`.split("\n").first)
    #@build_dir.chomp!("/")
    return @build_dir
  end

  #Helper that show points to location of binary tar ball
  def tar_bin_file
    (Config::PKG_DIR) +'/'+self.to_s+'-bin.tar.bz2'
  end
  
  # Helper that points to fake root install dir
  def install_dir
    (Config::FAKE_INSTALL_DIR) +'/'+self.to_s
  end
  
end
