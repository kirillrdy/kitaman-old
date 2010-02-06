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

require 'kitaman/kita_helper'
require 'kitaman/kitaman_helper'
require 'kitaman/kita.rb'
require '/etc/kitaman_conf'


# This is Make module
# It handles make driven apps building
#
# Usage
# Create a ruby file that will extend Make module
# Methods that you should overwrite
#
# def config
# end
#
#  # Confugure package
#  def config
#    "./configure --prefix=/usr"
#  end

#   # builds package
#   def build
#     "
#     make
#     "
#   end

#   def kita_install
#     "    
#     make DESTDIR=#{install_dir} install
#     "
#   end

#   def post_install
#     "echo 'nothing here'"
#   end
#  
#  def clean_up
#    "
#      # Update the linkers cache
#      ldconfig
#      echo 'Cleaning up'
#      rm -rf #{build_dir}
#      rm -rf #{install_dir}
#    "
#  end

#
module Make
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
    "./configure --prefix=/usr"
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
      result = (result and system("tar xjpf #{file} -C #{KITAMAN_BUILD_DIR}/")) if ( file.index('.tar.bz2') or file.index('.bz2') )
      result = (result and system("tar xpf #{file} -C #{KITAMAN_BUILD_DIR}/")) if ( file.index('.tar.gz') or file.index('.tgz'))
      result = (result and system("tar #{file} -d #{KITAMAN_BUILD_DIR}/")) if file.index('.zip')
    end
    return result
  end

  # Patch source code
  def patch
    result = true
    
    puts "Patching..."
    for file in files_list_local
      if file.index('.patch')
        file = File.basename(file)
        puts "Patching using #{file}".red
        result = result and system(build_enviroment + "cd #{build_dir} && patch -Np1 -i #{KITAMAN_SRC_DIR}/#{file}")
      end
    end
    return result
  end


  def install
    
    result = true
    # ruby
    
    result = result and extract
    
    #ruby    
    result = result and patch
    

    result = result and system("
      
      #{build_enviroment}

      #{config}

      #{build}

      #{kita_install}
          ") #config_src &> /var/kitaman/config_logs/#{self.to_s}
    
   
    result = result and create_package
    
    # This is an actual installing
    result = result and system(build_enviroment + "tar xjpf #{tar_bin_file} -C #{ENV['KITAMAN_INSTALL_PREFIX']}/")

    #TODO FIX 
    result = result and system("
    #{post_install}
    #{clean_up}
    ")
    
    record_installed
    
    return result
  end  
  
 

  # Generates tar ball with binary files
  def create_package
    system( build_enviroment  + "
    
    cd #{install_dir}

    tar cjpf #{tar_bin_file} *

    ")

  end
  

  # Records package as installed and records a list of all files installed by the package
  def record_installed
    `tar tf #{tar_bin_file} > #{state_file}`
  end

  ##########################################################################
  private
  ##########################################################################
  
  def build_dir
    @build_dir ||=  KITAMAN_BUILD_DIR + '/' + (`tar tf #{files_list_local[0]}`.split("\n")[0])
    #@build_dir.chomp!("/")
    return @build_dir
  end
  
  def tar_bin_file
    (KITAMAN_PKG_DIR) +'/'+self.to_s+'-bin.tar.bz2'
  end
  
  def install_dir
    (KITAMAN_FAKE_INSTALL_DIR) +'/'+self.to_s
  end
  
end
