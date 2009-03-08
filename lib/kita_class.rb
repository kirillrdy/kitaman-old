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


class Kita
  # Class that represents a package in Kitaman world
  attr_reader :info

  def ==(obj)
    self.info==obj.info
  end

  def to_s
    self.info['NAME-VER']
  end
  
  # Creates Kita object and parses all the information
  def initialize(kita_file)
    
    infos = IO.read(kita_file).scan(/(.*?)="(.*?)"\n/)
    @info = {}
    for info in infos
      @info[info[0]]=info[1]
    end

    @info.set_if_nil('NAME',File.basename(kita_file,".kita"))

    #sorry this line had to be this ugly, because get_files_from_repo gets evaluated here, and we dont always want it
    @info.split_or_default_if_nil('FILES',@info.has_key?('FILES') ? '' :  get_files_from_repo)

    
    @info.set_if_nil('VER',get_version)
    @info['NAME-VER'] = @info['NAME']+'-'+@info['VER'] 

    @info.split_or_default_if_nil("DEPEND",[])
    @info["BUILD"] = IO.read(kita_file).scan(/BUILD=""(.*?)""/m)[0][0] if @info['BUILD']

  end

  # Find kita file by package name
  def Kita.find_kita_file(package_name)
    found_file = `find #{KitamanConfig.config['KITA_FILES_DIR']} -type f | grep /#{package_name}.kita`.split("\n")
    if found_file.length == 0
      puts "No kitafile found for \'#{package_name}\'".red.bold
      exit
    end

    if found_file.length > 1
      puts "More than one kita file is found for #{package_name}".red.bold
      exit
    end
    
    return found_file[0]
    
  end

  # Get version from source file
  def get_version
    if @info['FILES']!=[]
      ver = @info['FILES'][0].version
    else
      ver = "0.0"
    end
    return ver
  end

  # Create a state file meaning that package is installed
  def record_installed
    `touch #{KitamanConfig.config['STATE_DIR']}/#{@info['NAME-VER']}`
  end

  # Fills FILES var with files maching in repository
  def get_files_from_repo
  
    if not File.exist?('/var/kitaman/src.db')
      update_src_files_database
    end
    
    files_list_database = Marshal.load(IO.read('/var/kitaman/src.db'))
    files_list_database[@info['NAME']] ? [files_list_database[@info['NAME']]] : []    
  end

  # Checks if package is installed
  def installed?
    File.exist?(KitamanConfig.config['STATE_DIR']+'/'+@info['NAME-VER'])
  end

  # Checks if package is build (sorry i know its built not builded, i had good reason to do so)
  def builded?
    File.exist?(KitamanConfig.config['PKG_DIR']+'/'+@info['NAME-VER']+'-bin.tar.bz2')
  end

  # Downloads all files in FILES var, returns True if all files downloaded successfully
  def download
    success=true
    for file in @info["FILES"] 
      success = (success and system("wget -c #{file} -O #{KitamanConfig.config['SRC_DIR']}/#{File.basename(file)}"))
    end
    return success
  end

  # Returns a list of full paths to local source files belonging to package
  def files_list_local
    list=[]
    for file in @info['FILES']
      list << (KitamanConfig.config['SRC_DIR']+'/'+File.basename(file))
    end
    list
  end

  # Returns a list of URLS of source files to be downloaded
  def files_list_to_download
    @info['FILES']
  end

  # Checks if all files are downloaded
  def downloaded?
    results = true
    for file in files_list_local 
      results = (results and not File.size?(file).in [0,nil])
    end
    return results
  end


end
