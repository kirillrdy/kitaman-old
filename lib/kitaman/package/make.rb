#    Kitaman - Software Package Manager
#    /-Promise to a little girl and a big world-/
#
#    Copyright (C) 2011  Kirill Radzikhovskyy <kirillrdy@kita-linux.org>
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


module Kitaman::Package::Make
  include Kitaman

  attr_accessor :sources, :patches, :prefix, :pre_configure_cmd, :configure_cmd, :additional_configure_cmd, :build_cmd, :install_cmd

  # Generates Build Enviroment for the package
  def build_enviroment_cmd
    "
    set -e
    export MAKEFLAGS='-j#{Computer.number_of_cores+1}'
    BUILD_DIR=#{build_dir}
    cd #{build_dir}
    "
  end

  def set_defaults
    
    @version = get_version_from_sources unless @version

    @sources = get_files_from_repo if @sources.empty?
    @patches = []
    @prefix = '/usr'
    @pre_configure_cmd = ''
    @configure_cmd = "./configure --prefix=#{@prefix}"
    @additional_configure_cmd = ''
    @build_cmd = 'make'
    @install_cmd = 'make install'
  end


  def clean_up_cmd
    "
      # Update the linkers cache
      ldconfig
      echo 'Cleaning up'
      rm -rf #{build_dir}
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
        result = result && Shell::execute(build_enviroment_cmd + "cd #{build_dir} && patch -Np1 -i #{Config::SRC_DIR}/#{file}")
      end
    end
    return result
  end


  def install

    download unless downloaded?

    result = true
    # ruby

    result = result && extract

    #ruby
    result = result && patch


    result = result && Shell::execute("
      
      #{build_enviroment_cmd}

      #{configure}

      #{build}

      #{kita_install}
          ")

    #TODO FIX 
    result = result && Shell::execute("
    
    # TODO fix post install
    # #{post_install}
    
    
    #{clean_up_cmd}
    ")

    record_installed

    return result
  end




  # Fills FILES var with files maching in repository
  def get_files_from_repo
    FilesDatabase.update_src_files_database if not File.exist?(Config::SRC_MARSHAL_FILE)

    @@files_list_database ||= Marshal.load(IO.read(Config::SRC_MARSHAL_FILE))
    @@files_list_database[@name] ? [@@files_list_database[@name]] : []
  end

  # helper method used to set @version
  # It will find version of first file availible for package
  # or return undefined which is bad, and prob should be an exception
  def get_version_from_sources
    files.first ? File.version(@files.first) : 'undefined'
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

  def remote_files
    (@files + @patches)
  end


  # Returns a list of full paths to local source files belonging to package
  def local_files
    remote_files.map {|x| Config::SRC_DIR+'/'+ File.basename(x) }
  end


  # Downloads all files in @files var, returns true if all files downloaded successfully
  def download
    success=true
    for file in remote_files
      success = (success and Downloader.download_file(file))
    end
    return success
  end

  # Checks if all files are downloaded
  def downloaded?
    results = true
    for file in local_files
      results = (results && File.exists?(file))
    end
    return results
  end

end
