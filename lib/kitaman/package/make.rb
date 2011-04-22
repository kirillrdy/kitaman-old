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

    @sources = get_files_from_repo if @sources.nil? || @sources.empty?
    @patches = []
    @version = get_version_from_sources unless @version

    @prefix = '/usr' unless @prefix
    @pre_configure_cmd = '' unless @pre_configure_cmd
    @configure_cmd = "./configure --prefix=#{@prefix}" unless @configure_cmd
    @additional_configure_cmd = '' unless @additional_configure_cmd
    @build_cmd = 'make' unless @build_cmd
    @install_cmd = 'make install' unless @install_cmd
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

    dir_to_extract_to = "#{Config::BUILD_DIR}/#{@name}"
    Shell::execute "mkdir -p #{dir_to_extract_to}"
    
    
    local_files.each do |file|
      Log.info "Extrating  #{file}..."

      result = (result && Shell::execute("tar xjpf #{file} -C #{dir_to_extract_to}/")) if ( file.index('.tar.bz2') || file.index('.bz2') )
      result = (result && Shell::execute("tar xJpf #{file} -C #{dir_to_extract_to}/")) if ( file.index('.tar.xz') || file.index('.xz') )
      result = (result && Shell::execute("tar xpf #{file} -C #{dir_to_extract_to}/")) if ( file.index('.tar.gz') || file.index('.tgz'))
      result = (result && Shell::execute("unzip #{file} -d #{dir_to_extract_to}/")) if file.index('.zip')
    end
    return result
  end

  # Patch source code
  def patch
    result = true
    
    
    for file in local_files
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

      #{configure_cmd}

      #{build_cmd}

      #{install_cmd}
          ")

    #TODO FIX 
    result = result && Shell::execute("

    # TODO fix post install
    # #{post_install_cmd}

    #{clean_up_cmd}
    ")

    record_installed

    return result
  end




  # Fills FILES var with files maching in repository
  def get_files_from_repo
    FilesDatabase.update if not File.exist?(Config::SRC_MARSHAL_FILE)

    @@files_list_database ||= Marshal.load(IO.read(Config::SRC_MARSHAL_FILE))
    @@files_list_database[@name] ? [@@files_list_database[@name]] : []
  end

  # helper method used to set @version
  # It will find version of first file availible for package
  # or return undefined which is bad, and prob should be an exception
  def get_version_from_sources
    remote_files.first ? File.version(remote_files.first) : 'undefined'
  end



  ##########################################################################
  private
  ##########################################################################

  # Helper that shows where source will be built
  # eg /var/kitaman/build/linux-2.6.26/
  def build_dir
    return @build_dir if @build_dir

#    target = `tar tf #{local_files.first}`.split("\n").first
#    target += '/' unless target.index '/'
#    target = target[0..target.index('/')]

    @build_dir ||=  "#{Config::BUILD_DIR}/#{@name}/*/"
    return @build_dir
  end

  def remote_files
    (@sources + @patches)
  end


  # Returns a list of full paths to local source files belonging to package
  def local_files
    remote_files.map {|x| Config::SRC_DIR+'/'+ File.basename(x) }
  end


  # Downloads all files in remote_files, returns true if all files downloaded successfully
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
