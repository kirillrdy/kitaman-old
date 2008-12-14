# This is the base class for Kita, all classes shall inherit from this class !

require 'kitaman/kita_helper'
require 'kitaman/kitaman_helper'


class Kita
  # Class that represents a package in Kitaman world
  attr_reader :info

  def ==(obj)
    self.info==obj.info
  end
  
  # Creates Kita object and parses all the information
  def initialize(kita_file)
    infos = IO.read(kita_file).scan(/(.*?)="(.*?)"\n/)
    @info = {}
    for info in infos
      @info[info[0]]=info[1]
    end

    @info.set_if_nil('NAME',File.basename(kita_file,".kita"))

    
    @info.split_or_default_if_nil('FILES',get_files_from_repo)

    
    @info.set_if_nil('VER',get_version)
    @info['NAME-VER'] = @info['NAME']+'-'+@info['VER'] 

    @info.split_or_default_if_nil("DEPEND",[])
    @info["BUILD"] = IO.read(kita_file).scan(/BUILD=""(.*?)""/m)[0][0] if @info['BUILD']

  end

  # Find kita file by package name
  def Kita.find_kita_file(package_name)
    all_files = `find #{KitamanConfig.config['KITA_FILES_DIR']} -type f`.split("\n")
    for file in all_files
      if File.basename(file,".kita") == package_name
        return file
      end
    end
    return nil
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
    files_list_database = Marshal.load(IO.read('/var/kitaman/src.db'))
    files_list_database[@info['NAME']] ? [files_list_database[@info['NAME']]] : []    
  end

  # Checks if package is installed
  def installed?
    File.exist?(KitamanConfig.config['STATE_DIR']+'/'+@info['NAME-VER'])
  end

  # Checks if package is build (sorry i know its build not builded, i had good reason to do so)
  def builded?
    File.exist?(KitamanConfig.config['PKG_DIR']+'/'+@info['NAME-VER']+'-bin.tar.bz2')
  end

  # Downloads all files in FILES var, returns True if all files downloaded successfully
  def download
    success=true
    for file in @info["FILES"] 
      success = success and Kernel.system("wget -c #{file} -O #{KitamanConfig.config['SRC_DIR']}/#{File.basename(file)}")
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
      results = (results and File.exist?(file))
    end
    return results
  end


end
